aws-functions
=============

Personally useful functions for dealing with AWS. Think of it as a Jen-friendly wrapper around aws cli with added cowsay.

Design motivation
------------

I have been using AWS a lot recently via the CLI. While it's complete and stable as I need it, for browsing and accessing information and performing certain tasks I find it a little too low level.

All these functions really do is present to me the information in a way I personally care about and with intuitive parameterisation. For me that's worth the extra layer on top of the aws cli.

For example:

```
function cfn-describe {
   aws cloudformation describe-stacks --stack-name "$1" | jq .
}

```

I am often wanting to just pull out information for a single stack. This lets me do it easily:

```
cfn-describe "my-awesome-stack"
```

I often have forgotten the name of my stack, so the following comes in handy (though I reckon I could do it a bit less heavy weight):

```
cfn-grep my-awesome
```


Disclaimer
-----------

If it is not clear yet, this library is really rather ideosyncratic and fitting to my particular needs. I think there is some promising stuff in there (like the partial-function-like application of the resource parameter as in ec2-describe) but it's built out of utility. Please copy/extend/modify as you want. Make it better and let me know about it so I can use your version instead :)

Possible also that there are existing tools that will work for me. But implementing these functions was definitely more fun than learning a new tool !



Requirements
------------

A few things you can install using your package manager of choice.
* Cowsay (yes really)
* jq
* boxes
* aws-cli


