@echo off
rem %1 ftp://user:password@server
rem %2 src_file
rem %3 dst_file

call %CONFIGURE_ENV_WIN32%

echo src_file: %2%
echo dst_file: %3%

echo option batch abort> ftpcmd.dat
echo option confirm off>> ftpcmd.dat
echo open %1>> ftpcmd.dat
echo put %2 %3>> ftpcmd.dat
echo exit>> ftpcmd.dat
winscp.com /script=ftpcmd.dat
del ftpcmd.dat