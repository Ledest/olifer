#DESCRIPTION

Olifer is lightweight validator supporting Language Independent Validation Rules Specification (LIVR) for Erlang

See http://livr-spec.org for detailed documentation and list of supported rules.

**Features:**

* Rules are declarative and language independent
* Any number of rules for each field
* Return together errors for all fields
* Excludes all fields that do not have validation rules described
* Has possibility to validatate complex hierarchical structures
* Easy to describe and undersand rules
* Returns understandable error codes(not error messages)
* Easy to add own rules
* Rules are be able to change results output ("trim", "nested_object", for example)
* Multipurpose (user input validation, configs validation, contracts programming etc)
 
#USAGE

1. Add as a dependency in your project.
2. Add in **your_project.app.src** file in tuple **applications**.
3. Run **olifer:start()**.
4. Thats all, now you can validate data, register your own rules or aliased built-in rules.

