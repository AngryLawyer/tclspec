package provide spec 0.1

source [file join [file dirname [info script]] "example.tcl"]
source [file join [file dirname [info script]] "example_group.tcl"]
source [file join [file dirname [info script]] "expectation_handler.tcl"]
source [file join [file dirname [info script]] "matcher.tcl"]
source [file join [file dirname [info script]] "reporter.tcl"]
source [file join [file dirname [info script]] "world.tcl"]
source [file join [file dirname [info script]] "runner.tcl"]

set world [Spec::World new]

proc describe { description block } {
    set group [Spec::ExampleGroup new $description]

    set ::current_group $group

    uplevel 1 $block

    $::world register $group

    unset ::current_group
}

proc it { description block } {
    $::current_group add [Spec::Example new $::current_group $description $block ]
}

proc before { what args } {
    if { [llength $args] == 0 } {
        set block $what
        set what "each"
    } else {
        set block [lindex $args 0]
    }

    $::current_group before $what $block
}

proc after { {what "each"} block } {
    if { [llength $args] == 1 } {
        set what "each"
        set block [lindex $args 0]
    } elseif { [llength $args] == 1 } {
        set what [lindex $args 0]
        set block [lindex $args 1]
    }

    $::current_group after $what $block
}

proc expect { actual to matcher args } {
    set positive true

    # Negative Expectation
    if { $matcher == "not" } {
        set positive false
        set matcher [lindex $args 0]
        set args [lrange $args 1 end]
    }

    if { $matcher == "be" } {
        set what [lindex $args 0]
        set args [lrange $args 1 end]

        if { $what == "true" } {
            set matcher [Spec::BeTrueMatcher new]
        } elseif { $what == "false" } {
            set matcher [Spec::BeFalseMatcher new]
        } elseif { $what in [list < <= > >= in ni] } {
            set expected [lindex $args 0]
            set matcher [Spec::BeComparedToMatcher new $expected $what]
        }
    } elseif { $matcher == "equal" } {
        set expected [lindex $args 0]
        set matcher [Spec::EqualMatcher new $expected]
    } elseif { $matcher == "change" } {
        set expected [lindex $args 0]
        set matcher [Spec::ChangeMatcher new $expected]
    } elseif { $matcher == "satisfy" } {
        set expected [lindex $args 0]
        set matcher [Spec::SatisfyMatcher new $expected]
    } elseif { $matcher == "raise_error"} {
        set matcher [Spec::RaiseErrorMatcher new]
    } else {
        error "Unknown Matcher: $matcher"
    }

    if { $positive } {
        Spec::PositiveExpectationHandler handle_matcher $actual $matcher
    } else {
        Spec::NegativeExpectationHandler handle_matcher $actual $matcher
    }
}