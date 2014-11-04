typedef enum {
    CCPackageStatusInitial = 0,
    CCPackageStatusDownloading = 1,
    CCPackageStatusDownloadPaused = 2,
    CCPackageStatusDownloadFailed = 3,
    CCPackageStatusDownloaded = 4,
    CCPackageStatusUnzipping = 5,
    CCPackageStatusUnzipped = 6,
    CCPackageStatusUnzipFailed = 7,
    CCPackageStatusInstallationFailed = 9,
    CCPackageStatusInstalledEnabled = 10,
    CCPackageStatusInstalledDisabled = 11,
    CCPackageStatusDeleted = 12
}
CCPackageStatus;
