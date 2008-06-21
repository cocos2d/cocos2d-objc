import struct
import random
import asyncore
import socket, time

HOST = ''
PORT = 0xAC3d
G=.4375 # 56 (de 0 a 128)

class AccelChannel(asyncore.dispatcher):
    def handle_read(self):
        data = self.recv(1024)
        if len(data)>0:
            self.server.broadcast(data, self)
            if len(data)>=12:
                print struct.unpack_from("<fff",data)

    def handle_write(self):
        pass
        #x, y, z = random.random()*G, random.random()*G, random.random()*G
        #self.send(struct.pack("<fff", x, y, z))

    def handle_close(self):
        self.server.remove_channel(self)
        self.close()

class AccelServer(asyncore.dispatcher):
    def __init__(self, host=HOST, port=PORT):
        asyncore.dispatcher.__init__(self)
        self.channels = []
        self.port = port
        self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
        self.bind((host, port))
        self.listen(5)
        print "listening on port", self.port

    def append_channel(self, c):
        c.server = self
        self.channels.append(c)

    def remove_channel(self, c):
        self.channels.remove(c)

    def handle_accept(self):
        channel, addr = self.accept()
        c = AccelChannel(channel)
        self.append_channel(c)

    def broadcast(self, data, src):
        for c in self.channels:
            if c is not src:
                c.send(data)

server = AccelServer()
asyncore.loop()
