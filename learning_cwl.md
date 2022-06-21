# CWL in a nutshell (not 😜)


## Conditionals 

To run a conditional, the input parameter that is used in the 
expression to be evaluated, needs to be part of the input of the step!! 
Not only in the `.cwl` main params. 




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



## [Document context](https://www.commonwl.org/v1.0/SchemaSalad.html#Document_model)

The implicit context consists of the vocabulary defined by the schema and the base URI. By default, the base URI must be the URI that was used to load the document. It may be overridden by an explicit context.

If a document consists of a root object, this object may contain the fields `$base`, `$namespaces`, `$schemas`, and `$graph`:





## Runtime environment (!)

Output files produced by tool execution must be written to the designated output directory. The initial current working directory when executing the tool must be the designated output directory.





### Requirements & hints

A process `requirement` modifies the semantics or runtime environment of a process. 
If an implementation cannot satisfy all requirements, or a requirement is listed which is not recognized by the implementation, it is a fatal error and the implementation must not attempt to run the process, unless overridden at user option.

A `hint` is similar to a requirement; however, it is not an error if an implementation cannot satisfy all hints. 
The implementation may report a warning if a hint cannot be satisfied.


Often tool descriptions will be written for a specific version of a software. 
To make it easier for others to use your descriptions, you can include a `SoftwareRequirement` field in the `hints` section. 
This may also help to avoid confusion about which version of a tool the description was written for.
Here is an example: 

```cwl
hints:
  SoftwareRequirement:
    packages:
      interproscan:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_005829" ]
        version: [ "5.21-60" ]
```


**Do not confuse with `requirements`**.
`requirements` are 

requirements:
  ResourceRequirement:
    ramMin: 10240
    coresMin: 3
  SchemaDefRequirement:
    types:
      - $import: InterProScan-apps.yml


      
Optionally, implementations may allow requirements to be specified in the input object document as an array of requirements under the field name `cwl:requirements`. 
If implementations allow this, then such requirements should be combined with any requirements present in the corresponding Process as if they were specified there.

**Requirements specified in a parent Workflow are inherited by step processes if they are valid for that step**. If the substep is a `CommandLineTool` only the `InlineJavascriptRequirement`, `SchemaDefRequirement`, `DockerRequirement`, `SoftwareRequirement`, `InitialWorkDirRequirement`, `EnvVarRequirement`, `ShellCommandRequirement`, `ResourceRequirement` are valid.

*As good practice, it is best to have process requirements be self-contained, such that each process can run successfully by itself.*

**`Requirements` override `hints`**. If a process implementation provides a process requirement in hints which is also provided in requirements by an enclosing workflow or workflow step, the enclosing requirements takes precedence.

> When a tool runs under CWL, the starting working directory is the designated output directory.


### Test your tool

Once you have built your `.cwl` and your `.yml` files, you need to figure out whether your `tool` is working ok. 
To do that, run the step your `tool` implements and keep track of its exact output. 
Then, you may build a second `.yml` file (we will call it `tools-tests.yml`) which is like that: 

```yaml=
- job: tools/my_tool/my_tool_test.yml
  tool: ../../tools/tool/my_tool.cwl
  short_name: my_tool.cwl
  doc: "TOOL"
  output:
    tool_output:
      location: Any
      basename: toul_output
      class: Directory
      listing:
      - class: File
      ..
      ..
      ..

```

For a more complete example, you may see [here](https://github.com/mberacochea/microbetag/blob/78140c451ff7034a3bbc6ac1ec34efe9d0b8b742/tests/cwl/tools-tests.yml).



`cwltest` does:
- runs the cwl file with the .yml input file
- compares the output values



```cwl=

```

## Important links to guide you 

A few rather important links to get to know the CWL framework: 

- [Runtime environment](https://www.commonwl.org/v1.0/CommandLineTool.html#Runtime_environment)
- [Writing workflows](https://www.commonwl.org/user_guide/21-1st-workflow/index.html)
- [Best practicies](https://doc.arvados.org/v1.3/user/cwl/cwl-style.html)




Tutorials: 

- [Getting started with CWL](https://docs.dockstore.org/en/1.11.0/getting-started/getting-started-with-cwl.html)


```cwl=
outputs:
  compiled_class:
    type: File
    outputSource: compile/classfile
```
The `outputs` section describes the outputs of the workflow. 
This is a **list** of output parameters where each parameter consists of an identifier and a data type. 
The `outputSource` connects the output parameter `classfile` of the `compile` step to the workflow output parameter `compiled_class`.




## Toil 

Note!  Toil checks if the docker image specified by TOIL_APPLIANCE_SELF  exists  prior  to
    launching  by  using  the  docker  v2  schema.   This should be valid for any major docker
    repository, but there is  an  option  to  override  this  if  desired  using  the  option:
    `--forceDockerAppliance`.


