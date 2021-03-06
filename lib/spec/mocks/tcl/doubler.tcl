namespace eval ::Spec::Mocks::Tcl {
    nx::Class create Doubler {
        :property [list proc_doubles [dict create]]

        # Make this a singleton
        :public class method create {args} {
            if { ![info exists :instance] } {
                set :instance [next]
            }

            if { ![[::Spec::Mocks space] includes? ${:instance}] } {
                [::Spec::Mocks space] add ${:instance}
            }

            return ${:instance}
        }

        :public class method stub_call { proc_name -with -and_return {-once:switch false} {-twice:switch false} {-never:switch false} {-any_number_of_times:switch false} -exactly:optional -at_least:optional -at_most:optional {block {}} } {
            set expectation [[:new] add_stub $proc_name $block]

            if { [info exists with] } {
                $expectation with $with
            }

            if { $once } {
                $expectation once
            }

            if { $twice } {
                $expectation twice
            }

            if { $never } {
                $expectation never
            }

            if { $any_number_of_times } {
                $expectation any_number_of_times
            }

            if { [info exists exactly] } {
                $expectation exactly $exactly
            }

            if { [info exists at_least] } {
                $expectation at_least $at_least
            }

            if { [info exists at_most] } {
                $expectation at_most $at_most
            }

            if { [info exists and_return] } {
                $expectation and_return $and_return
            }

            return $expectation
        }

        :public class method mock_call { proc_name -with -and_return {-once:switch false} {-twice:switch false} {-never:switch false} {-any_number_of_times:switch false} -exactly:optional -at_least:optional -at_most:optional {block {}} } {
            set expectation [[:new] add_message_expectation $proc_name $block]

            if { [info exists with] } {
                $expectation with $with
            }

            if { $once } {
                $expectation once
            }

            if { $twice } {
                $expectation twice
            }

            if { $never } {
                $expectation never
            }

            if { $any_number_of_times } {
                $expectation any_number_of_times
            }

            if { [info exists exactly] } {
                $expectation exactly $exactly
            }

            if { [info exists at_least] } {
                $expectation at_least $at_least
            }

            if { [info exists at_most] } {
                $expectation at_most $at_most
            }

            if { [info exists and_return] } {
                $expectation and_return $and_return
            }

            return $expectation
        }

        :public class method dont_call { proc_name -with } {
            set expectation [[:new] add_negative_message_expectation $proc_name]

            if { [info exists with] } {
                $expectation with $with
            }

            return $expectation
        }

        :protected method init {} {
            set :error_generator [::Spec::Mocks::Tcl::ErrorGenerator new]
        }

        :public method message_received { proc_name args } {
            set expectation [:find_matching_expectation $proc_name {*}$args]
            set stub [:find_matching_method_stub $proc_name {*}$args]

            set level [expr { [info level] - 2 }]

            if { $stub != false && ($expectation == false || [$expectation called_max_times?]) } {
                if { $expectation != false && [$expectation actual_received_count_matters?] } {
                    $expectation increase_actual_receive_count
                }

                $stub invoke $level {*}$args
            } elseif { $expectation != false } {
                $expectation invoke $level {*}$args
            } elseif { [set expectation [:find_almost_matching_expectation $proc_name {*}$args]] != false } {
                if { ![:has_negative_expectation? $proc_name] } {
                    [:raise_unexpected_message_args_error $expectation {*}$args]
                }
            } else {
                [:raise_unexpected_message_error $proc_name {*}$args]
            }
        }

        :public method raise_unexpected_message_args_error { expectation args } {
            ${:error_generator} raise_unexpected_message_args_error $expectation {*}$args
        }

        :public method raise_unexpected_message_error { expectation args } {
            ${:error_generator} raise_unexpected_message_error $expectation {*}$args
        }

        :public method has_negative_expectation? { proc_name } {
            foreach expectation [[:proc_double_for $proc_name] expectations] {
                if { [$expectation negative_expectation_for? $proc_name] } {
                    return true
                }
            }

            return false
        }

        :public method find_matching_expectation { proc_name args } {
            [:proc_double_for $proc_name] find_matching_expectation {*}$args
        }

        :protected method find_almost_matching_expectation { proc_name args } {
            [:proc_double_for $proc_name] find_almost_matching_expectation {*}$args
        }

        :protected method find_matching_method_stub { proc_name args } {
            [:proc_double_for $proc_name] find_matching_method_stub {*}$args
        }

        :public method add_message_expectation { proc_name {block {}} } {
            [:proc_double_for $proc_name] add_expectation ${:error_generator} $block
        }

        :public method add_negative_message_expectation { proc_name } {
            [:proc_double_for $proc_name] add_negative_expectation ${:error_generator}
        }

        :public method add_stub { proc_name {implementation {}} } {
            [:proc_double_for $proc_name] add_stub ${:error_generator} $implementation
        }

        :public method remove_stub { proc_name } {
            [:proc_double_for $proc_name] remove_stub
        }

        :public method proc_double_for { proc_name } {
            if { ![dict exists ${:proc_doubles} $proc_name] } {
                set pd [ProcDouble new -message_name $proc_name]
                dict set :proc_doubles $proc_name $pd
            }

            dict get ${:proc_doubles} $proc_name
        }

        :public method spec_verify {} {
            dict for {_ proc_double} ${:proc_doubles} {
                $proc_double verify
            }
        }

        :public method spec_reset {} {
            dict for {_ proc_double} ${:proc_doubles} {
                $proc_double reset
            }
        }
    }
}
