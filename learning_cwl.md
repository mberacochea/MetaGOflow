# CWL in a nutshell (not 😜)


## Data concepts

An **`object`** is a data structure equivalent to the "object" type in JSON, consisting of a *unordered* set of **name/value pairs** (referred to here as **`fields`**) and where the name is a `string` and the value is a `string`, `number`, `boolean`, `array`, or `object`.

> **`fields`** is a key term! 

A **`document`** is a file containing a serialized `object`, or an `array` of `objects`.

A **`process`** is a basic unit of computation which accepts input data, performs some computation, and produces output data. 
Examples include `CommandLineTools`, `Workflows`, and `ExpressionTools`.

An **`input object`** is an object describing the inputs to an invocation of a process. 
The **fields** of the input object are referred to as "input **parameters**". 
Likewise for the **`output object`**.


An **`input schema`** describes the valid format (required fields, data types) for an input object.
Similarly for the case of `output schema`.



The **`inputs`** section describes the inputs of the tool. 
This is a ***mapped** list of input parameters* 
(see the [YAML Guide](https://www.commonwl.org/user_guide/yaml/#maps) for more about the format) and each parameter includes an **identifier**, a **data type**, and *optionally* an **inputBinding**. 
>The **`inputBinding`** describes how this input parameter should appear on the command line. 

For example:

```bash=
  inputBinding:
    position: 2
    prefix: -i
    separate: false
```
where

- `position`: the value of position is used to determine where parameter should appear on the command line
- `separate`: when `false`, the prefix and value are combined into a single argument
- `prefix`  : argument on the command line before the parameter



## Execution concepts

A parameter is a named symbolic input or output of process, with an associated datatype or schema. During execution, values are assigned to parameters to make the input object or output object used for concrete process invocation.

A CommandLineTool is a process characterized by the execution of a standalone, non-interactive program which is invoked on some input, produces output, and then terminates.

A workflow is a process characterized by multiple subprocess steps, where step outputs are connected to the inputs of downstream steps to form a directed acylic graph, and independent steps may run concurrently.

A runtime environment is the actual hardware and software environment when executing a command line tool. It includes, but is not limited to, the hardware architecture, hardware resources, operating system, software runtime (if applicable, such as the specific Python interpreter or the specific Java virtual machine), libraries, modules, packages, utilities, and data files required to run the tool.

A workflow platform is a specific hardware and software implementation capable of interpreting CWL documents and executing the processes specified by the document. The responsibilities of the workflow platform may include scheduling process invocation, setting up the necessary runtime environment, making input data available, invoking the tool process, and collecting output.

A workflow platform may choose to only implement the Command Line Tool Description part of the CWL specification.






