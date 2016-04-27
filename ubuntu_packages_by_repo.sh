#!/bin/bash

########## README ################################
## Quick & simple Bash script to query a list of installed Ubuntu repos, prompt 
## user for a choice of repo, & lists all packages available from the repo.

########## REQUIREMENTS ##########################
## This script pre-supposes a standard repo location (/var/lib/apt/lists)
## and file access permissions to this path.

## Clear Terminal Screen
clear

## Create Array Of Repos
declare -a repoList=()
for i in $(ls /var/lib/apt/lists/ | grep _Packages)
do
    echo $i
    repoList=("${repoList[@]}" "$i")
done

RepoCount=${#repoList[@]}
echo "Total Count Of Repos: " $RepoCount

## Enumerate Repo List & Display To User
for ((i=0;$i<$RepoCount;i++))
do
    if [[ "${repoList[$i]}" =~ "archive.ubuntu" ]]
    then
    rname=${repoList[$i]##*archive.ubuntu}
    echo "$i RepoName: " "${rname%%_binary*}"
    elif [[ "${repoList[$i]}" =~ "ubuntu" ]]
    then
    echo "$i RepoName: " "${repoList[$i]%%_ubuntu*}"
    else
    echo "$i RepoName: " "${repoList[$i]%%_dist*}"
    fi
done

## Prompt User For Repo Choice
read -p "Select the repo number: " repoNumber

## Create Array Of Packages In Selected Repo
packages=()
for i in $(cat /var/lib/apt/lists/${repoList[$repoNumber]} | grep Package)
do
    if ! [[ "$i" =~ "Package" ]]
    then
    packages=("${packages[@]}" "$i")
    fi
done

## Number Packages In Repo
packageNumber=${#packages[@]}

## Create Function To List Packages
function listPackages () {
    for ((i=0;$i<$packageNumber;i++))
    do
    echo ${packages[$i]}
    done
}

## Display Sorted Package List, Piped To Less If More Than 30
if test $packageNumber -gt 30
then
    listPackages | sort | less
else
    listPackages | sort
fi
echo "Total Packages In This Repo: " $packageNumber
