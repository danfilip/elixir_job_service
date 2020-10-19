# Elixir Job Service

## About

A simple http service that receives a list of unordered tasks and their dependencies and sorts them in the proper order of execution

The expected request body looks like this:

```
{
    "tasks" : [
        {
            "name" : "task-2",
            "command" : "cat file.txt",
            "requires" : ["task-3"]
        },
        {
            "name" : "task-1",
            "command" : "ls -l"        
        },
        {
            "name" : "task-3",
            "command" : "shutdown",
            "requires" : ["task-1"]
        },
        {
            "name" : "task-4",
            "command" : "ifconfig",
            "requires" : ["task-2", "task-3"]
        }                        
    ]
}
```

There are two endpoints:

- **POST /job/sort** : sorts the tasks and returns them in proper order, in json format

The expected response is:

```
{
  "tasks":[
    {
      "name":"task-1",
      "command":"ls -l"
    },
    {
      "name":"task-3",
      "command":"shutdown"
    },
    {
      "name":"task-2",
      "command":"cat file.txt"
    },
    {
      "name":"task-4",
      "command":"ifconfig"
    }
  ]
}
```
- **POST /job/script** : sorts the tasks and builds a script(text) by joining all task commands

```
#/bin/bash
ls -l
shutdown
cat file.txt
ifconfig
```

## Test

Simply run: ``` mix test ``` and see the test result in the ```test\test\requests\results\[scripts|tasks]``` folder

OR

run ```mix run --no-halt``` to start the webserver and perform any of the two requests on http://localhost:2345

## Test Cases

There are a few test scenarios each with its own separate json test file located in the ```test\test_requests``` subfolder
