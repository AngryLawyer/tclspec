namespace eval ::Spec::Mocks::nx {
    namespace path ::Spec::Mocks
}

source [file join [file dirname [info script]] "nx" "error_generator.tcl"]
source [file join [file dirname [info script]] "nx" "method_double.tcl"]
source [file join [file dirname [info script]] "nx" "methods.tcl"]
source [file join [file dirname [info script]] "nx" "mock.tcl"]
source [file join [file dirname [info script]] "nx" "proxy.tcl"]