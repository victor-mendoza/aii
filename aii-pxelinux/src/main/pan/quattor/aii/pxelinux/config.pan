# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}
template quattor/aii/pxelinux/config;

include 'quattor/aii/pxelinux/schema';

@documentation{
    Use sys/pxelinux with lpxelinux.0
    Tested with pxelinux.0 gpxelinux.0 chain.c32 ldlinux.c32 lpxelinux.0 from SYSLINUX 6.03,
    should work since 5.10.
}
variable LPXELINUX ?= false;

@documentation{
    Relative path from the AII_OSINSTALL_PATH. defaults to images/pxeboot
}
variable LPXELINUX_OSINSTALL_PATH ?= "images/pxeboot";

@documentation{
    Base HTTP URL to find vmlinuz and initrd
}
variable LPXELINUX_ROOT ?= format("http://%s%s/%s", AII_OSINSTALL_SRV, AII_OSINSTALL_PATH, LPXELINUX_OSINSTALL_PATH);

#
# Kickstart file location
# defaults to the /ks directory on the KS installation server
#
variable AII_KS_PATH ?= {
    if (match (AII_OSINSTALL_PROTOCOL, "http")) {
        return("/ks");
    } else {
        return("/osinstall/ks");
    };
};

variable AII_KS_CONFIG_FILE ?= AII_KS_PATH + "/" + AII_HOSTNAME + "." + AII_DOMAIN + ".ks";
"/system/aii/nbp/pxelinux/kslocation" ?= {
    if (AII_OSINSTALL_PROTOCOL == "http") {
        s = "http://" + AII_KS_SRV;
    } else {
        s = "nfs:" + AII_KS_SRV + ":";
    };
    return(s + AII_KS_CONFIG_FILE);
};


"/system/aii/nbp/pxelinux/ksdevice" ?= boot_nic();


#
# Label for the boot loader
#
variable AII_NBP_LABEL ?= {
    if ( !is_defined(AII_OSINSTALL_OS_VERSION) ) {
        return(undef);
    };
    toks =  matches(AII_OSINSTALL_OS_VERSION, '^(slc?|rhel|centos|fedora)(\w+?)[_\-](.*)');
    if ( length(toks) < 4 ) {
        label = undef;
    } else {
        if ( toks[1] == 'centos' ) {
            label = 'CentOS ';
        } else if ( toks[1] == 'fedora' ) {
            label = 'Fedora ';
        } else if ( toks[1] == 'sl' ) {
            label = 'Scientific Linux ';
        } else if ( toks[1] == 'slc' ) {
            label = 'Scientific Linux CERN ';
        } else if ( toks[1] == 'rhel' ) {
            label = 'Red Hat Entreprise Linux ';
        } else {
            label = undef;
        };
        if ( is_defined(label) ) {
            label = label + toks[2] + ' ('+ toks[3] + ')';
        };
    };
    label;
};

"/system/aii/nbp/pxelinux/label" ?= {
    if ( is_defined(AII_NBP_LABEL) ) {
        AII_NBP_LABEL;
    } else if ( is_defined(AII_OSINSTALL_OS_VERSION) ) {
        format("Linux %s", AII_OSINSTALL_OS_VERSION);
    } else {
        undef;
    };
};

#
# Relative path (from /tftpboot) of the initial ram disk and kernel.
# By default use 'version_arch'.
#
variable AII_NBP_ROOT ?= {
    if ( !is_defined(AII_OSINSTALL_OS_VERSION) ) {
        return(undef);
    };

    if (LPXELINUX) {
        root = LPXELINUX_ROOT;
    } else {
        toks =  matches(AII_OSINSTALL_OS_VERSION, '^(\w+?)[_\-](.*)');
        if ( length(toks) < 3 ) {
            root = undef;
        } else {
            root = toks[1] + '_'+ toks[2];
            if (length (toks) > 3) {
                root = root + toks[3];
            };
        };
    };
    root;
};

"/system/aii/nbp/pxelinux/kernel" ?=
    if ( is_defined(AII_OSINSTALL_OS_VERSION) ) {
        format('%s/vmlinuz', AII_NBP_ROOT);
    } else {
        undef;
    };

variable AII_NBP_INITRD ?= "initrd.img";

"/system/aii/nbp/pxelinux/initrd" ?=
    if ( is_defined(AII_OSINSTALL_OS_VERSION) ) {
        format('%s/%s', AII_NBP_ROOT, AII_NBP_INITRD);
    } else {
        undef;
    };

variable AII_NBP_KERNELPARAMS ?= null;

"/system/aii/nbp/pxelinux/append" ?= AII_NBP_KERNELPARAMS;
