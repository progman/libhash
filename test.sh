#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
APP='./bin/hash';
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# run app
function run_app()
{
	if [ "${FLAG_VALGRIND}" != "1" ];
	then
		STDOUT=$(cat | ${APP} "${@}");
	else
		VAL="valgrind --tool=memcheck --leak-check=yes --leak-check=full --show-reachable=yes --log-file=valgrind.log";

		STDOUT=$(cat | ${VAL} ${APP} "${@}");

		echo '--------------------------' >> valgrind.all.log;
		cat valgrind.log >> valgrind.all.log;
		rm -rf valgrind.log;
	fi


	if [ "${STDOUT}" != "" ];
	then
		echo "${STDOUT}";
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function check()
{
	HASH=${3};
	RESULT=$(echo -n "${1}" | run_app -"${2}");
	if [ "${RESULT}" != "${HASH}" ];
	then
		echo "ERROR: result different for "${2}"...";
		echo "RESULT : ${RESULT}";
		echo "HASH   : ${HASH}";
		exit 1;
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# test1
function test1()
{
	check 'Mom'                                   'crc16' 'ca0d';
	check 'Mom wash'                              'crc16' '6afd';
	check 'Mom wash window frame'                 'crc16' 'fec0';
	check 'Mom wash window frame and Shura balls' 'crc16' 'c19a';
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# test2
function test2()
{
	check 'Mom'                                   'crc32' '5665ad0c';
	check 'Mom wash'                              'crc32' '2769fdb4';
	check 'Mom wash window frame'                 'crc32' '660246ce';
	check 'Mom wash window frame and Shura balls' 'crc32' '18a5b32d';
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# test3
function test3()
{
	check 'Mom'                                   'sha1' '0967082f2aa15d0a0c0acc03ed8e64555840f63f';
	check 'Mom wash'                              'sha1' '6d56273df975bbc6ef1eed1ec18368843647588c';
	check 'Mom wash window frame'                 'sha1' '3fa55a9fbceb88f31faaa8f69b04a109ffddc3aa';
	check 'Mom wash window frame and Shura balls' 'sha1' '95afdf31b23f267e97b88c88553cdd325d9f5b52';
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(which ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
if [ ! -e "${APP}" ];
then
	echo "ERROR: make it";
	exit 1;
fi


check_prog "cat echo rm";
if [ "${?}" != "0" ];
then
	exit 1;
fi


test1;
test2;
test3;


echo "ok, test passed";
exit 0;
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
