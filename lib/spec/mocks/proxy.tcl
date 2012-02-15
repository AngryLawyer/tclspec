namespace eval Spec {
    namespace eval Mocks {
        nx::Class create Proxy {
            :property object:required
            :property {name ""}

            :property [list method_doubles [dict create]]

            :public method add_message_expectation { message {block {}} } {
                [:method_double_for $message] add_expectation $block
            }

            :public method add_negative_message_expectation { message } {
                [:method_double_for $message] add_negative_expectation
            }

            :public method add_stub { method_name {implementation {}} } {
                [:method_double_for $method_name] add_stub $implementation
            }

            :public method remove_stub { method_name } {
                [:method_double_for $method_name] remove_stub
            }

            :variable null_object false

            :public method null_object? {} {
                expr { ${:null_object} }
            }

            :public method as_null_object {} {
                set :null_object true
                return ${:object}
            }

            :public method has_negative_expectation? { method_name } {
                foreach expectation [[:method_double_for $method_name] expectations] {
                    if { [$expectation negative_expectation_for? $method_name] } {
                        return true
                    }
                }

                return false
            }

            :public method message_received { method_name args } {
                set expectation [:find_matching_expectation $method_name {*}$args]
                set stub [:find_matching_method_stub $method_name {*}$args]

                if { $stub != false && ($expectation == false || [$expectation called_max_times?]) } {
                    if { $expectation != false } {
                        $expectation increase_actual_receive_count
                    }

                    $stub invoke {*}$args
                } elseif { $expectation != false } {
                    $expectation invoke {*}$args
                } elseif { [set expectation [:find_almost_matching_expectation $method_name {*}$args]] != false } {
                    if { ![:has_negative_expectation? $method_name] && ![:null_object?] } {
                        return -code error -errorcode ::Spec::Mocks::ExpectationError "Received unexpected call to $method_name"
                    }
                }
            }

            :public method find_matching_expectation { method_name args } {
                [:method_double_for $method_name] find_matching_expectation {*}$args
            }

            :protected method find_almost_matching_expectation { method_name args } {
                [:method_double_for $method_name] find_almost_matching_expectation {*}$args
            }

            :protected method find_matching_method_stub { method_name args } {
                [:method_double_for $method_name] find_matching_method_stub {*}$args
            }

            :public method method_double_for { message } {
                if { ![dict exists ${:method_doubles} $message] } {
                    dict set :method_doubles $message [MethodDouble new \
                        -object ${:object} \
                        -method_name $message \
                        -proxy [:]
                    ]
                }

                dict get ${:method_doubles} $message
            }

            :public method verify {} {
                dict for {_ method_double} ${:method_doubles} {
                    $method_double verify
                }
            }

            :public method reset {} {

            }
        }
    }
}