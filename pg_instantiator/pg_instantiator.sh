#!/bin/bash

# This script is a wrapper for initdb
# it creates a complete directory structure 
# according to ASPICON best practices
# and calls initdb to create a new instance


#   CHANGELOG
#   ---------------------------------------------------------
#   JJJJ-MM-DD      <name>      <change>

#   2021-03-24      mde         initial creation



#   ---------------------------------------------------------------------------------------------------
#
#   PREPARATION
#

set +u
# avoid globbing (expansion of *)
set -f
 
# unalias all
unalias which 2>/dev/null
unalias awk 2>/dev/null
unalias cut 2>/dev/null
unalias dirname 2>/dev/null
unalias egrep 2>/dev/null
unalias sed 2>/dev/null
unalias tr 2>/dev/null
unalias hostname 2>/dev/null
unalias sort 2>/dev/null
unalias uniq 2>/dev/null
unalias basename 2>/dev/null
unalias uname 2>/dev/null
unalias echo 2>/dev/null
unalias netstat 2>/dev/null

# platform stuff
AWK_BIN=$( command -v awk )
BASENAME_BIN=$( command -v basename )
CAT_BIN=$( command -v cat)
SED_BIN=$( command -v sed )
SORT_BIN=$( command -v sort )
UNIQ_BIN=$( command -v uniq )
CUT_BIN=$( command -v cut )
GREP_BIN=$( command -v egrep )
ALIAS_BIN=$( command -v alias )
HOSTNAME_BIN="$( command -v hostname ) -s"
UNAME_BIN=$( command -v uname )
WHOAMI_BIN=$( command -v whoami )
GETENT_BIN=$( command -v getent )
# services
SYSCTL_BIN=$( command -v systemctl )
# system
IP_BIN=$( command -v ip )
ETHT_BIN=$( command -v ethtool )
DMI_BIN=$( command -v dmidecode)
DF_BIN=$( command -v df )
FREE_BIN=$( command -v free )
LSCPU_BIN=$( command -v lscpu)
NETSTAT_BIN=$( command -v netstat )
GETCONF_BIN=$( command -v getconf )
IP_BIN=$( command -v ip )
HNC_BIN=$( command -v hostnamectl )
LSBLK_BIN=$( command -v lsblk )
STAT_BIN=$( command -v stat )
# users
SU_BIN=$( command -v su )
ENV_BIN=$( command -v env )
GROUP_BIN=$( command -v groups )
ID_BIN=$( command -v id )
# string manipulations
HEAD_BIN=$( command -v head)
WC_BIN=$( command -v wc )
TR_BIN=$( command -v tr )
# files and directories
PWD_BIN=$( command -v pwd )
RM_BIN="$( command -v rm ) -f"
MKDIR_BIN=$( command -v mkdir )
CHOWN_BIN=$( command -v chown )
CHMOD_BIN=$( command -v chmod )

# shell-specific settings
# csh stores name of shell in ${SHELL} instead of ${SHELL}
FOUND_SHELL=$( ${BASENAME_BIN} "${SHELL}" 2>/dev/null )
if [ "${FOUND_SHELL}X" = "X" ]; then
    FOUND_SHELL=$( ${BASENAME_BIN} "${SHELL}" )
fi
 
case ${FOUND_SHELL} in
     bash|sh|ksh)
         export EXPORT=export
         ;;
    csh|tcsh)
        export EXPORT=set
        ;;
esac

# tell bash not to store duplicates
${EXPORT} HISTCONTROL=ignoreboth
 
case "$( ${UNAME_BIN} -s )" in
    Linux)
        export ECHO_BIN=$( which echo)" -e"
        ;;
    *)
        export ECHO_BIN=$( which echo)
        ;;
esac

declare -r STROK="\e[32mOK\e[0m     "
declare -r STRIF="\e[34mINFO\e[0m   "
declare -r STRWN="\e[33mWARNING\e[0m"
declare -r STRER="\e[31mERROR\e[0m  "


#   ---------------------------------------------------------------------------------------------------
#
#   FUNCTIONS
#

# welcome header
welcome() {
    ${ECHO_BIN} "Welcome to the NetPolGen"

    ${ECHO_BIN} "\n(c) Copyright 2021 ASPICON GmbH <support@aspicon.de>"
    ${ECHO_BIN} "All rights reserved.\n"
}

# usage
usage() {
    ${ECHO_BIN} "This script uses the \"hlm-netpolgen\" chart to create netpol manifests\n"
    ${ECHO_BIN} "Script version: ${NETPOLGEN_VERSION}\n"

    ${ECHO_BIN} "Usage: ocp_netpolgen.sh <options>"

    ${ECHO_BIN} "Options"
    ${ECHO_BIN} "    -h | --help         show this help"
    ${ECHO_BIN} "    -t | --tpl-dir      path to netpolgen chart"
    ${ECHO_BIN} "    -b | --helm-bin     path to helm binary"
    ${ECHO_BIN} "    -s | --skip         skip n lines of dry-run output"
    ${ECHO_BIN} "    -m | --manifest     path to netpol manifest"
    ${ECHO_BIN} "    -o | --output       path to output file"
    exit 0
}

# check and install packages - yum
pgpkg-yum() {
    local VERSION=${1}
    if [ $( yum list installed | grep postgresql${VERSION} | wc -l ) -lt 4 ]; then
        ${ECHO_BIN} "${STRIF} -- PostgreSQL ${VERSION} binaries not installed or not complete, installing now"
        yum -y -q  install postgresql${VERSION}-libs.x86_64 postgresql${VERSION}-contrib.x86_64 postgresql${VERSION}-libs.x86_64 postgresql${VERSION}-server.x86_64 > /dev/zero 2>&1
    fi
}

# function to create directory layout
create_dirs() {
    local INST_BASE="/u02/app/postgres"
    local BASE_MODE="0750"
    local DATA_MODE="0700"
    if [ $# == 1 ]; then
        local INST_NAME=${1}
        local USER="postgres"
        local GROUP="postgres"
    else
        if [ $# == 2 ]; then
            local USER=${2}
            local GROUP=${2}
        else
            local GROUP=${3}
        fi
    fi

    if [ -d "${INST_BASE}/${INST_NAME}" ]; then
        ${ECHO_BIN} "${STRER} -- Instance home \"${INST_NAME}\" aalready exists."
    else
        ${MKDIR_BIN} -p -m ${BASE_MODE} ${INST_BASE}/${INST_NAME}
        ${MKDIR_BIN} -m ${DATA_MODE} ${INST_BASE}/${INST_NAME}/PGDATA
        ${MKDIR_BIN} -m ${DATA_MODE} ${INST_BASE}/${INST_NAME}/config
        ${MKDIR_BIN} -m ${BASE_MODE} ${INST_BASE}/${INST_NAME}/logs
        ${MKDIR_BIN} -m ${BASE_MODE} ${INST_BASE}/${INST_NAME}/tls
        if [ -z ${CD_SKIP_SCRIPTS}]; then
            ${MKDIR_BIN} -m ${BASE_MODE} ${INST_BASE}/${INST_NAME}/scripts
        fi
        if [ -z ${CD_SKIP_ARCHIVE}]; then
            ${MKDIR_BIN} -m ${DATA_MODE} ${INST_BASE}/${INST_NAME}/archive
        fi
        if [ -z ${CD_SKIP_BACKUP}]; then
            ${MKDIR_BIN} -m ${DATA_MODE} ${INST_BASE}/${INST_NAME}/BACKUP
        fi
        ${CHOWN_BIN} -R ${USER}:${GROUP} ${INST_BASE}
    fi
}

#   ---------------------------------------------------------------------------------------------------
#
#   SCRIPT CONFIGURATION
#



#   ---------------------------------------------------------------------------------------------------
#
#   SANITY CHECK
#

# test if run as root
if [[ $EUID -ne 0 ]]; then
    ${ECHO_BIN} "${STRER} -- This script must be run as root!"
    ${ECHO_BIN} "\n    for help run : instantiator.sh {-h|--help}\n"
    exit 1
fi



