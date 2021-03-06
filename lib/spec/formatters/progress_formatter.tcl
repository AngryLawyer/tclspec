namespace eval Spec {
    namespace eval Formatters {
        oo::class create ProgressFormatter {
            superclass ::Spec::Formatters::BaseTextFormatter

            method example_passed { example } {
                next $example
                puts -nonewline [my _success_color "."]
            }
    
            method example_failed { example } {
                next $example
                puts -nonewline [my _failure_color "F"]
            }

            method example_pending { example } {
                next $example
                puts -nonewline [my _pending_color "*"]
            }
    
            method start_dump {} {
                next
                puts ""
            }
        }
    }
}
