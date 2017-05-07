#!/bin/bash
set -e

supervisorctl stop all
service supervisor stop
exit