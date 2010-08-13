#!/usr/bin/perl -W

# Author: Matthias Hoechsmann, gamedrs.com
# Artefact Removal using Edge Copy by Patrick Wolowicz, subzero.eu
# This source code an be used freely and is provided "AS IS" without any warrenties.
# Go and visit www.zombiesmash.gamedrs.com. Thank you :)

# STEPS to install GD module on mac
# 1. Install libpng/libjpeg binaries http://ethan.tira-thompson.org/Mac_OS_X_Ports.html
# 2. Download and install libdg http://www.libgd.org
# 3. Download and install GD perlmodule (Can be done with CPAN, perl -MCPAN -e 'shell', get GD, make GD, install GD)

# README
# mkatlas.pl is a perl script for generating an atlas image from individual images and a C header file with image coordinates. 
# mkAtlas.pl takes a *.atl file in the following format and turns it into a png/pvr atlas.
# Format: each line is <imagename>[,+<scale factor img>][,-<scale factor code],[*<alternative variable name], square brackets are optional
# Here is an example and some further explaination:
#
# File foreground.atl has the following content
# interface/houseEnergy/Housebar_barcolor_01.png,+1.5
# emptyslot.png,+2,-0.5
# interface/houseEnergy/Housebar_houseonly_concept01.png,*housebar_concept
#
# mkatlas.pl will pack all these images in one Atlas image foregroundAtlas.png. It will also create the pvr and pvr_png preview,
# named foregroundAtlas.pvr and foregroundAtlas_pvrprev.png. mkatlas.pl also create header files with coordinates that can be used
# for atlas sprites. In particular, it creates a file foregroundCoords.h that could look like
#
# #define COORDS_FOREGROUND_HOUSEBAR_BARCOLOR_01 CGRectMake(1,19,1,7)
# #define SCALE_FOREGROUND_HOUSEBAR_BARCOLOR_01 1
# #define COORDS_FOREGROUND_EMPTYSLOT CGRectMake(38,33,44.8,44.8)
# #define SCALE_FOREGROUND_EMPTYSLOT 0.5
# #define COORDS_FOREGROUND_HOUSEBAR_CONCEPT CGRectMake(309,1,28,28)
# #define SCALE_FOREGROUND_HOUSEBAR_CONCEPT 1
#
# For each line in the *.atl file, a rectangle and a scale factor is defined in the header file
# As default, the scale factor is 1 and can be ignored. Sometimes though you want to scale a sprite in your code. 
# In particular, to improve pvr sprites you could scale the image up when copying it to the atlas and scale a sprite that uses the
# image down by the same proportion. This often gives better results than just using the pvr image 1:1.
# ",+1.5" scales Housebar_barcolor_01.png by factor 1.5 when copying it to the atlas. Thus, the rectangle will be 1.5 times as big as the
# original image. 
# ",+2,-0.5" scales the original image by factor 2. It also generates a SCALE define set to 0.5. 
# ",*housebar_concept" sets the define name. Otherwise, its deduced from the filename.
#
# For generating the atlas, call mkatlas like:
# ./mkatlas.pl -p 2 -s 512 -f foreground/foreground.atl -r ..
# -p sets the spacing for images. Here 2 pixels. When you use pvr, you want to increase the spacing to reduce artefacts
# -s 512 sets the atlas image size to 512 pixels. The number must be a power of 2.
# -f sets the atl file with lines as described above
# -r sets the root directory for images. All paths from the atl file are relative to this directory
#
# Happy coding! - Matthias

# Changes
# 10-08-02 added support for improved artefact removal with -p > 2 (required for mip mapping)
# 09-13-09 improved artefact removal when called with -p 2, removed warning about init not initialized
# 08-16-09 fixed bug: alpha channel not copied for first image in atl file

use GD;
use Getopt::Std;
use vars qw/ %opt /;

my @images;  # global array that holds hashrefs of images including id, and size
my %opt; #global array holding options

# change the path if texturetool is installed somewhere else
$texturetool = "/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool";

&init();
&main();

# packing algorithm based on http://www.blackpawn.com/texts/lightmaps/default.html

sub insertImg()
{
    my ($node, $img) = @_;
    
#    print "w: $node->{W}, h: $node->{H}\n";
	
    # if we're not a leaf then
    if($node->{CHILDA} != 0 || $node->{CHILDB} != 0)
    {
	# (try inserting into first child)
	$newNode = &insertImg($node->{CHILDA}, $img);
	return $newNode if($newNode != 0);

	# (no room, insert into second)
	$newNode = &insertImg($node->{CHILDB}, $img);
	return $newNode;
    }
    else
    {
	# (if there's already a texture here, return)
	return 0 if($node->{IMG_REF} != 0);
		    
	# (if we're too small, return)
	return 0 if($img->{W} > $node->{W} || $img->{H} > $node->{H});	    

	# (if we're just right, accept)	
	if($node->{W} == $img->{W} && $node->{H} == $img->{H})
	{
	    $node->{IMG_REF} = $img;
	    return $node;
	}

	# (otherwise, gotta split this node and create some kids)
	my %childa = (IMG_REF => 0, CHILDA => 0, CHILDB => 0);
	my %childb = (IMG_REF => 0, CHILDA => 0, CHILDB => 0);

        # (decide which way to split)
        my $dw = $node->{W} - $img->{W};
        my $dh = $node->{H} - $img->{H};
        
        if($dw > $dh)
	{
	    # split vertically
	    $childa{LEFT} = $node->{LEFT};
	    $childa{BOTTOM} = $node->{BOTTOM};
	    $childa{W} = $img->{W};
	    $childa{H} = $node->{H};

	    $childb{LEFT} = $node->{LEFT} + $img->{W};
	    $childb{BOTTOM} = $node->{BOTTOM};
	    $childb{W} = $node->{W} - $img->{W};
	    $childb{H} = $node->{H};
	}
        else
	{
	    # split horizontally
	    $childa{LEFT} = $node->{LEFT};
	    $childa{BOTTOM} = $node->{BOTTOM};
	    $childa{W} = $node->{W};
	    $childa{H} = $img->{H};

	    $childb{LEFT} = $node->{LEFT};
	    $childb{BOTTOM} = $node->{BOTTOM} + $img->{H};
	    $childb{W} = $node->{W};
	    $childb{H} = $node->{H} - $img->{H};	    
	}

	$node->{CHILDA} = \%childa;
	$node->{CHILDB} = \%childb;
 
	# (insert into first child we created)
	$newNode = &insertImg($node->{CHILDA}, $img);
	return $newNode;
    }
}

sub usage()
{
    print "mkatlas -f configfile [-s size] [-r imgrootdir] [-p pvrspacing]\n";
    exit;
}

sub init()
{
    use Getopt::Std;
    my $opt_string = 'hf:s:r:p:';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if $opt{h} || !$opt{f};
    $opt{s} = 128 if(!defined($opt{s}));
    $opt{r} = "" if(!defined($opt{r}));
	$opt{p} = 0 if(!defined($opt{p}));	

	die("Error: -p must be a multiple of 2") if($opt{p} % 2 == 1);
	
    printf("Options: s=$opt{s}, r=$opt{r}, p=$opt{p}\n");
}

sub main
{
    my $num_images = 0;

    # read config file
    open(IN, '<', $opt{f}) || die ("Cannot open file: $opt{f}\n"); 
    foreach my $line (<IN>)
    {
	# skip comment lines (//)
	if($line =~ /^\/\// || $line =~ /^\s*$/)
	{
	    next;
	}
	else
	{
		$scaleUp = 1;
		$scaleDown = 1;
		$altName = "";  
		
	    # open image file and get stats
		if($line =~ /^(.*?),(.*)$/)
		{
			$filename = "$opt{r}/$1";			
			my $rest = $2;
			$scaleUp = $1 if($rest =~ /\+(\d+\.?\d*)/);
			$scaleDown = $1 if($rest =~ /-(\d+\.?\d*)/);
			$altName = $1 if($rest =~ /\*(.\w*)/);
		}
		else
		{
			$filename = "$opt{r}/$line";
		}
		
	    $gd_image = GD::Image->new($filename);
	    die("Error: Cannot open image file $filename\n") if(!$gd_image);
	    ($width,$height) = $gd_image->getBounds();
	    
	    my %image = (FILENAME => $filename,
					 W => ($width*$scaleUp)+$opt{p},
					 H => ($height*$scaleUp)+$opt{p},
					 SCALEUP => $scaleUp,
					 SCALEDOWN => $scaleDown,
					 ALTNAME => $altName,
					 W_ORG => $width,
					 H_ORG => $height);
		
	    push(@images, \%image);
	    chop($line);
	    printf("$filename -> w: $width, h: $height\n");
	    
	}
    }
    close(IN);

    # build coordinate tree
    my %atlasParam = (W => $opt{s}, H => $opt{s});
    my %node = (LEFT => 0, BOTTOM => 0, W => $atlasParam{W}, H => $atlasParam{H}, IMG_REF => 0, CHILDA => 0, CHILDB => 0);

    foreach $image (@images)
    {
	$res = &insertImg(\%node, $image);
	die("Error: Image '$image->{FILENAME} could not be inserted, increase Atlas size") if(!$res);
    }

    # generate Atlas image and header
    my $file_prefix = "";
    my $file_prefix_short = "";
    $file_prefix = $1 if ($opt{f} =~ /^(.*)\.atl$/);
    $file_prefix = $opt{f} if($file_prefix eq "");
    $file_prefix_short = $file_prefix;
    $file_prefix_short =~ s/.*\/(.*)/$1/;
    $atlasParam{PREFIX} = uc($file_prefix_short);

    print("# new coordinates\n");
    my $gd_atlas = GD::Image->newTrueColor($atlasParam{W}, $atlasParam{H});
    $gd_atlas->saveAlpha(1);
    $gd_atlas->alphaBlending(0);
    $atlasParam{ATLAS_REF} = $gd_atlas;

    open (H, '>', "${file_prefix}Coords.h");
    $atlasParam{HEADER_FH} = H;
    print H "// This file was automatically created by mkatlas.pl\n\n";

    &generateAtlas(\%node, \%atlasParam);
    $png_data = $gd_atlas->png(0);
    open (OUT,'>', "${file_prefix}Atlas.png") || die("Cannot open atlas.png");
    binmode OUT;
    print OUT $png_data;
    close OUT;

    close(H);
	
	# create pvr texture file
	my $call = "$texturetool -o \"${file_prefix}Atlas.pvr\" -f PVR -e PVRTC -p \"${file_prefix}Atlas_pvrprev.png\" \"${file_prefix}Atlas.png\"";print "Calling $call\n";
    system($call); 	
}

sub generateAtlas
{
    my ($node, $atlasParam) = @_;
    $init = 0;
    if($node->{IMG_REF})
    {
	my $img = $node->{IMG_REF};
	print "$img->{FILENAME}: $node->{LEFT}, $node->{BOTTOM}, $node->{W}, $node->{H}\n";

#	GD::Image->trueColor(1);
	my $gd_image_src = GD::Image->new($node->{IMG_REF}->{FILENAME});
	$gd_image_src->saveAlpha(1);
	$gd_image_src->alphaBlending(0);
	$gd_image_src->trueColor(1);
	my $margin = $opt{p}/2;	
	my $x_dest = $node->{LEFT};
	my $y_dest = $node->{BOTTOM};
	my $w_src = $node->{IMG_REF}->{W_ORG};
	my $h_src = $node->{IMG_REF}->{H_ORG};	
	my $scaleUp = $node->{IMG_REF}->{SCALEUP};
	my $scaleDown = $node->{IMG_REF}->{SCALEDOWN}; 	
	my $w_dst = $w_src*$scaleUp;
	my $h_dst = $h_src*$scaleUp;
	my $altName = $node->{IMG_REF}->{ALTNAME};	
		
	#copy image to atlas	
	if($scaleUp == 1)
	{
		$atlasParam->{ATLAS_REF}->copy($gd_image_src, $x_dest+$margin, $y_dest+$margin, 0, 0, $w_src, $h_src);
	}
	else
	{
		$atlasParam->{ATLAS_REF}->copyResized($gd_image_src, $x_dest+$margin, $y_dest+$margin, 0, 0, $w_dst, $h_dst, $w_src, $h_src);
	}

	# fix alpha bug 
	# For the first image, I duplicated the code so it reads & writes the first image again in the same spot.
	# For whatever reason, it works.  Must be some weird bug in one of the libraries your using.		
	if( $init == 0 )			
	{
		$init = 1;
		
		my $gd_image_src = GD::Image->new($node->{IMG_REF}->{FILENAME});
		$gd_image_src->saveAlpha(1);
		$gd_image_src->alphaBlending(0);
		$gd_image_src->trueColor(1);
		if($scaleUp == 1)
		{
			$atlasParam->{ATLAS_REF}->copy($gd_image_src, $x_dest+$margin, $y_dest+$margin, 0, 0, $w_src, $h_src);
		}
		else
		{
			$atlasParam->{ATLAS_REF}->copyResized($gd_image_src, $x_dest+$margin, $y_dest+$margin, 0, 0, $w_dst, $h_dst, $w_src, $h_src);
		}
	}		
		
		
	# fill surrounding margin with image
	if($margin != 0)
	{
			for ($counter = 0; $counter < $margin;$counter++)
			{
				$atlasParam->{ATLAS_REF}->copy($atlasParam->{ATLAS_REF},$x_dest+$margin, $y_dest+$counter,$x_dest+$margin,$y_dest+$margin,$w_dst,1); #upper
				$atlasParam->{ATLAS_REF}->copy($atlasParam->{ATLAS_REF},$x_dest+$margin, $y_dest+($margin*2)+$h_dst-$counter-1,$x_dest+$margin,$y_dest+$h_dst+$margin-1,$w_dst,1); #lower
			}
			for ($counter = 0; $counter < $margin;$counter++)
			{
				$atlasParam->{ATLAS_REF}->copy($atlasParam->{ATLAS_REF},$x_dest+$counter,$y_dest,$x_dest+$margin,$y_dest,1,$h_dst+$margin*2);#left
				$atlasParam->{ATLAS_REF}->copy($atlasParam->{ATLAS_REF},$x_dest+$margin+$w_dst+$counter,$y_dest,$x_dest+$w_dst+$margin-1,$y_dest,1,$h_dst+$margin*2);#right
			}

	}
			
    #generate header line
	if($altName eq "")
	{
		$name = uc($1) if ($node->{IMG_REF}->{FILENAME} =~ /^(.*)\..*$/);
		$name = $1 if($name =~ /^.*\/(.*)$/);
	}
	else
	{
		$name = uc($altName);
	}
	$coordsName = "COORDS_$atlasParam->{PREFIX}_$name";
	$scaleName = "SCALE_$atlasParam->{PREFIX}_$name";
	$x_coord = ${x_dest}+$margin;
	$y_coord = ${y_dest}+$margin;	
	print {$atlasParam->{HEADER_FH}} "#define $coordsName CGRectMake($x_coord,$y_coord,$w_dst,$h_dst)\n";
	print {$atlasParam->{HEADER_FH}} "#define $scaleName $scaleDown\n";
    }

    &generateAtlas($node->{CHILDA}, $atlasParam) if($node->{CHILDA});
    &generateAtlas($node->{CHILDB}, $atlasParam) if($node->{CHILDB});
}
