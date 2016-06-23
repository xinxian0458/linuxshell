#!/bin/bash

CLUSTER_PATH=/linker
IMAGE_NAME=$1

if [[ -z ${IMAGE_NAME} ]]; then
	echo "Usage: upgrade.sh linkerrepository/linkerdcos_client:1.1.1"
	exit 1
else
	echo "will upgrade ${IMAGE_NAME} on all clusters."
fi

get_swarm_master() {
	if [[ -z $1 ]]; then
		echo "Usage: get_swarm_master [storage_path]"
		# exit 1
	fi
	local storage_path=$1
	SWARM_MASTER=$(docker-machine -s ${storage_path} ls | grep master | awk '{print $1}')
}

clear_docker_env() {
	docker_envs=$(env | grep DOCKER)
	for docker_env in docker_envs; do
		unset ${docker_env}
	done
}

# for each user, upgrade all clusters of him
users=$(ls ${CLUSTER_PATH}/docker)
for user in ${users}
do
	user_machine_path=${CLUSTER_PATH}/docker/${user}
	user_compose_path=${CLUSTER_PATH}/swarm/${user}
	clusters=$(ls ${user_machine_path})
	for cluster in ${clusters};do
		cluster_machine_path=${user_machine_path}/${cluster}
		cluster_compose_path=${user_compose_path}/${cluster}
		echo "upgrading user[${user}], cluster[${cluster}], storage_path=${cluster_machine_path}"

		#echo "get swarm_master"
		SWARM_MASTER=$(docker-machine -s ${cluster_machine_path} ls | grep master | awk '{print $1}')
		if [[ ! -z ${SWARM_MASTER} ]]; then
			#echo "set DOCKER envs"
			eval $(docker-machine -s ${cluster_machine_path} env --swarm ${SWARM_MASTER})
			echo "DOCKER_ENVS=$(env | grep DOCKER)"
			#echo "find instances"
			founded_container_ids=`docker ps | grep ${IMAGE_NAME} | awk '{print $1}'`
			if [[ ! -z ${founded_container_ids} ]]; then
				instances=0
				service_name=
				for container_id in ${founded_container_ids}; do
					echo "processing ${container_id}"
					#echo "upgrade docker image on specified machine"
					host=$(docker inspect -f {{.Node.Name}} ${container_id})
					service_name=$(docker inspect ${container_id} | grep -e "com.docker.compose.service" | awk '{print $2}' | sed 's/[\","]//g')
					docker $(docker-machine -s ${cluster_machine_path} config ${host}) pull ${IMAGE_NAME}
					#echo "kill old client"
					docker rm -f ${container_id}
					instances=`expr ${instances} + 1`
				done
				#echo "start new instances"
				if [[ ! -z ${service_name} ]]; then
					docker-compose -f ${cluster_compose_path}/docker-compose-user.yml scale ${service_name}=${instances}
				else
					echo "service_name is \"\""
				fi
			else
				echo "not found client."
			fi
		else
			echo "not found swarm master."
		fi
	done
done
echo "DONE"
exit 0

