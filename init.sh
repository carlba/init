#!/bin/bash

REPO_URI='https://raw.githubusercontent.com/carlba/.editorconfig/master'

curl -sO ${REPO_URI}/.prettierrc
curl -sO ${REPO_URI}/.editorconfig
