source [file join [file dirname [info script]] "methods_mixin.tcl"]

namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        nx::Class create MessageExpectation {
            :property method_name:required
            :property method_block
            :property {expected_receive_count 1}

            :variable actual_receive_count 0

            :public method matches_args? { args } {
                if { [info exists :expected_args] } {
                    expr { $args == ${:expected_args} }
                } else {
                    return true
                }
            }

            :public method negative_expectation_for? { name } {
                return false
            }

            :public method has_method_block? {} {
                expr { [info exists :method_block] && ${:method_block} != {} }
            }

            :public method called_max_times? {} {
                expr { ${:expected_receive_count} > 0 && ${:actual_receive_count} >= ${:expected_receive_count} }
            }

            :public method verify_messages_received {} {
                if { ![:expected_messages_received?] } {
                    :generate_error
                }
            }

            :public method once {} {
                set :expected_receive_count 1
            }

            :public method twice {} {
                set :expected_receive_count 2
            }

            :public method never {} {
                set :expected_receive_count 0
            }

            :public method with { arguments } {
                set :expected_args $arguments
            }

            :public method generate_error {} {
                return -code error -errorcode ::Spec::Mocks::ExpectationError "Message Expectation failed"
            }

            :public method expected_messages_received? {} {
                expr { [:matches_exact_count?] }
            }

            :public method matches_exact_count? {} {
                expr { ${:expected_receive_count} == ${:actual_receive_count}}
            }

            :public method increase_actual_receive_count {} {
                incr :actual_receive_count
            }

            :public method invoke { args } {
                :increase_actual_receive_count

                if { ${:expected_receive_count} == 0 } {
                    return -code error -errorcode ::Spec::Mocks::ExpectationError "Expected ${:method_name} not to be called"
                }

                set result ""
                if { [:has_method_block?] } {
                    set result [apply ${:method_block} {*}$args]
                }

                return $result
            }
        }

        nx::Class create NegativeMessageExpectation -superclass MessageExpectation {
            :public method init {} {
                set :expected_receive_count 0
            }

            :public method negative_expectation_for? { name } {
                expr { $name == ${:method_name}}
            }
        }

        nx::Class create Mock -mixin MethodsMixin {
            :property {name ""}

            :protected method unknown { method_name args } {
                if { ![:null_object?] } {
                    return -code error -errorcode ::Spec::Mocks::ExpectationError "Received unexpected call to $method_name"
                }
            }
        }
    }
}