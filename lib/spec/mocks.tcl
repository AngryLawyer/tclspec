source [file join [file dirname [info script]] "mocks/argument_expectation.tcl"]
source [file join [file dirname [info script]] "mocks/message_expectation.tcl"]
source [file join [file dirname [info script]] "mocks/example_methods.tcl"]
source [file join [file dirname [info script]] "mocks/arguments_matchers.tcl"]
source [file join [file dirname [info script]] "mocks/space.tcl"]
source [file join [file dirname [info script]] "mocks/abstract.tcl"]
source [file join [file dirname [info script]] "mocks/tcl.tcl"]
source [file join [file dirname [info script]] "mocks/nx.tcl"]

namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec
    }

    nx::Class create Mocks {
        :variable superspace:object [::Spec::Mocks::Space new]

        :public object method space {} {
            if {[info exists :superspace] == 0} {
                set :superspace [::Spec::Mocks::Space new]
            }
            return ${:superspace}
        }

        :public object method setup { host_namespace } {
            namespace eval $host_namespace {
                namespace import ::Spec::Mocks::ExampleMethods::*
            }

            nx::Object require trait ::Spec::Mocks::nx::Methods
        }

        :public object method verify {} {
            [:space] verify_all
        }

        :public object method teardown {} {
            [:space] reset_all
        }
    }
}
