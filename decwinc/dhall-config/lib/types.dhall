{-
types
-}

let EnsureType = < `Absent` | `Present` >
let FilesystemDecl = { ensure : EnsureType, path : Text, name : Text, text: Text }
let RegistryValueType = < `Dword` | `Qword` >
let RegistryDecl = { ensure : EnsureType, path : Text, name : Text, type: RegistryValueType, value: Text }

let ActivationHookDecl = { command : Text, args : List Text }

in { EnsureType = EnsureType
   , FilesystemDecl = FilesystemDecl
   , RegistryValueType = RegistryValueType
   , RegistryDecl = RegistryDecl

   , ActivationHookDecl = ActivationHookDecl


   , RootType = { filesystem: List FilesystemDecl
               , activationHooks: List ActivationHookDecl
               }
}