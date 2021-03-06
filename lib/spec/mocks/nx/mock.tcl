source [file join [file dirname [info script]] "methods.tcl"]

namespace eval ::Spec::Mocks::nx {
    nx::Class create Mock {
        :require trait ::Spec::Mocks::nx::Methods

        :property {name ""}
        :property {options {}}

        :public method init {} {
            :require namespace
        }

        :protected method unknown { method_name args } {
            if { ![:null_object?] } {
                [:__mock_proxy] raise_unexpected_message_error $method_name {*}$args
            }
        }
    }
}
