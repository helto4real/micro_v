# Module design

## Import statement
### Single name 
When import has a single name:
```V
import module_name
```
it can be ether a built-in module or a module. Search order:
- built-in modules directory
- file current directory
- check if any match by traversing the folders until stop

## Traverse the folders

- imports are converted to paths: import net.http -> net/http
- the folder of file that has import as base
    - traverse up in folder structure until find v.mod file
        - if v.mod found or stop (.git dir or too many levels)
            if v.mod found mark all paths with the root
            else if v.mod not found, mark alla path with module
