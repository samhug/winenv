{-
types
-}

let EnsureType = < Absent | Present >

let FilesystemDecl =
      { ensure : EnsureType, path : Text, name : Text, text : Text }

let ActivationHookDecl = { command : Text, args : List Text }

in  { EnsureType
    , FilesystemDecl
    , ActivationHookDecl
    , RootType =
        { filesystem : List FilesystemDecl
        , activationHooks : List ActivationHookDecl
        }
    }
