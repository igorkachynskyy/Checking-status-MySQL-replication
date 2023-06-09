#!/bin/bash
### VARIABLES ### \
EMAIL="igor.kachynskyy@gmail.com"
#MYSQL_CHECK=$(mysql -e "SHOW VARIABLES LIKE '%version%';" || echo 1)
LAST_ERRNO=$(mysql -h mysql_slave -P 3306 -u root -p'111' -e 'SHOW SLAVE STATUS \G'  | grep "Last_Errno" | awk '{ print $2 }' || echo 0)
SECONDS_BEHIND_MASTER=$(mysql -h mysql_slave -P 3306 -u root -p'111' -e 'SHOW SLAVE STATUS \G' | awk '{ print $2 }' || echo 0)
IO_IS_RUNNING=$(mysql -h mysql_slave -P 3306 -u root -p'111' -e 'SHOW SLAVE STATUS \G' | awk '{ print $2 }' || echo MULL)
SQL_IS_RUNNING=$(mysql -h mysql_slave -P 3306 -u root -p'111' -e 'SHOW SLAVE STATUS \G' | awk '{ print $2 }' || echo NO)
ERRORS=()

### Run Some Checks ###

## Check if I can connect to Mysql ##
# if [ "$MYSQL_CHECK" == 1 ]
# then
#     ERRORS=("${ERRORS[@]}" "Can't connect to MySQL (Check Pass)")
# fi

## Check For Last Error ##
if [ "$LAST_ERRNO" != 0 ]
then
    ERRORS=("${ERRORS[@]}" "Error when processing relay log (Last_Errno)")
fi

## Check if IO thread is running ##
if [ "$IO_IS_RUNNING" != "Yes" ]
then
    ERRORS=("${ERRORS[@]}" "I/O thread for reading the master's binary log is not running (Slave_IO_Running)")
fi

## Check for SQL thread ##
if [ "$SQL_IS_RUNNING" != "Yes" ]
then
    ERRORS=("${ERRORS[@]}" "SQL thread for executing events in the relay log is not running (Slave_SQL_Running)")
fi

## Check how slow the slave is ##
if [ "$SECONDS_BEHIND_MASTER" == "NULL" ]
then
    ERRORS=("${ERRORS[@]}" "The Slave is reporting 'NULL' (Seconds_Behind_Master)")
elif [ "$SECONDS_BEHIND_MASTER" > 60 ]
then
    ERRORS=("${ERRORS[@]}" "The Slave is at least 60 seconds behind the master (Seconds_Behind_Master)")
fi

### Send and Email if there is an error ###
if [ "${#ERRORS[@]}" -gt 0 ]
then
    MESSAGE="An error has been detected on ${SERVER} involving the mysql replciation. Below is a list of the reported errors:\n\n
    $(for i in $(seq 1 ${#ERRORS[@]}) ; do echo "\t${ERRORS[$i]}\n" ; done)
    Please correct this ASAP
    "
    echo -e $MESSAGE | mail -s "Mysql Replication for $SERVER is reporting Error" ${EMAIL}
fi