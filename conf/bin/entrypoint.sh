#!/bin/bash

set -o pipefail
set -o errtrace
set -o nounset
set -o errexit

sleep $SLEEP_LENGTH
LIQUIBASE_OPTS="$LIQUIBASE_OPTS --defaultsFile=/liquibase.properties"

echo -n > /liquibase.properties

echo "driver: ${LIQUIBASE_DRIVER}" >> /liquibase.properties
echo "classpath: ${LIQUIBASE_CLASSPATH}" >> /liquibase.properties
echo "url: ${LIQUIBASE_URL}" >> /liquibase.properties
echo "username: ${LIQUIBASE_USERNAME}" >> /liquibase.properties
echo "password: ${LIQUIBASE_PASSWORD}" >> /liquibase.properties
echo "contexts: ${LIQUIBASE_CONTEXTS}" >> /liquibase.properties
echo "changeLogFile: ${LIQUIBASE_CHANGELOG}" >> /liquibase.properties

function executeLiquibase() {
    echo $(pwd)
    echo $(ls)
	exec /opt/liquibase/liquibase "$@"
}

function liquibaseArguments(){
	array=("$@")
	unset "array[${#array[@]}-1]"
	echo ${array[*]}
}

if [[ "$#" -ge 1 ]]; then

	TASK="${@: -1}"
	liquibaseArg=$(liquibaseArguments $@)

	if [[ "$1" = "liquibase" ]]; then
		shift
		executeLiquibase $@
		exit 0
	fi

	case $1 in
		liquibase) executeLiquibase $@;;
		config) cat /liquibase.properties;;
		help) executeLiquibase --help;;
		update|updateCount|updateSQL|updateCountSQL) ;&
 	        rollback|rollbackToDate|rollbackCount|rollbackSQL|rollbackToDateSQL|rollbackCountSQL|updateTestingRollback|generateChangeLog) ;&
	        diff|diffChangeLog) ;&
        	dbDoc) ;&
	        status|validate|changelogSync|changelogSyncSQL|markNextChangeSetRan|listLocks|releaseLocks|dropAll|clearCheckSums)
        	        executeLiquibase $liquibaseArg $LIQUIBASE_OPTS $TASK
			exit 1;;
	esac
fi