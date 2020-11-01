let Value
    : Type
    = < DWORD : Natural | QWORD : Natural | SZ : Text >

let Entry
    : Type
    = { path : Text, name : Text, value : Value }

in  { Entry, Value }
