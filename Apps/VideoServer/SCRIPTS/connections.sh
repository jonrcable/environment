#!/bin/sh
#
## Calomel.org VsFTPd Watcher -- vsftpd_watcher.sh
#
while [ 1 ]
  do
    clear
    echo "  Calomel.org VsFTPd watcher                      `date`"
    echo ""
    ps -C vsftpd -o user,pid,stime,cmd
    echo ""
  # echo "----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--"
  # echo "usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw "
    dstat 1 5
done
