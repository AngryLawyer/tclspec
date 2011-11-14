lappend auto_path [file join [file dirname [info script]] ".." ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "expect to change, with a numeric value" {
    before each {
        my set value 0
    }

    it "passes if the actual value is modified by the block" {
        my instvar value

        expect { incr value } to change { set value }
    }

    it "fails if the actual value is not modified by the block" {
        my instvar value

        expect {
            expect {} to change { set value }
        } to fail_with "result should have changed, but is still '0'"
    }
}

describe "expect to not change, with a numeric value" {
    before each {
        my set value 0
    }

    it "passes if the actual value is not modified by the block" {
        my instvar value

        expect {} to not change { my set value }
    }

    it "fails if the actual value is modified by the block" {
        my instvar value

        expect {
            expect { incr value } to not change { set value }
        } to fail_with "result should not have changed, but did change from '0' to '1'"
    }
}

describe "expect to not change, with a list" {
    before each {
        my set value {}
    }

    it "passes if the actual value is modified by the block" {
        my instvar value

        expect { lappend value "test" } to change { set value }
    }

    it "fails if the actual value is not modified by the block" {
        my instvar value

        expect {
            expect {} to change { set value }
        } to fail_with "result should have changed, but is still ''"
    }
}

describe "expect to not change, with a numeric value" {
    before each {
        my set value {}
    }

    it "passes if the actual value is not modified by the block" {
        my instvar value

        expect {} to not change { set value }
    }

    it "fails if the actual value is modified by the block" {
        my instvar value

        expect {
            expect { lappend value "test" } to not change { set value }
        } to fail_with "result should not have changed, but did change from '' to 'test'"
    }
}

describe "expect to change by" {
    before each {
        my set value 0
    }

    it "passes if the actual value is changed by the expected amount" {
        my instvar value

        expect { incr value 4 } to change { set value } by 4
    }

    it "passes if the actual value is not changed and the expected amount is 0" {
        my instvar value

        expect { incr value 0 } to change { set value } by 0
    }

    it "fails if the actual value is changed by an unexpected amount" {
        my instvar value

        expect {
            expect { incr value 2 } to change { set value } by 4
        } to fail_with "result should have been changed by '4', but was changed by '2'"
    }
}

describe "expect to change by_at_most" {
    before each {
        my set value 0
    }

    it "passes if the actual value is changed by less than the expected amount" {
        my instvar value

        expect { incr value 2 } to change { set value } by_at_most 4
    }

    it "passes if the actual value is changed by the expected amount" {
        my instvar value

        expect { incr value 4 } to change { set value } by_at_most 4
    }

    it "fails if the actual value is changed by more than the expected amount" {
        my instvar value

        expect {
            expect { incr value 5 } to change { set value } by_at_most 4
        } to fail_with "result should have been changed by at most '4', but was changed by '5'"
    }
}

describe "expect to change by_at_least" {
    before each {
        my set value 0
    }

    it "passes if the actual value is changed by less than the expected amount" {
        my instvar value

        expect { incr value 5 } to change { set value } by_at_least 4
    }

    it "passes if the actual value is changed by the expected amount" {
        my instvar value

        expect { incr value 4 } to change { set value } by_at_least 4
    }

    it "fails if the actual value is changed by less than the expected amount" {
        my instvar value

        expect {
            expect { incr value 2 } to change { set value } by_at_least 4
        } to fail_with "result should have been changed by at least '4', but was changed by '2'"
    }
}

describe "expect to change from" {
    before each {
        my set value "string"
    }

    it "passes when the actual value is equal to the expected value before executing the block" {
        my instvar value

        expect { set value "other string" } to change { set value } from "string"
    }

    it "fails when the actual value is not equal to the expected value before executing the block" {
        my instvar value

        expect {
            expect { set value "foo" } to change { set value } from "bar"
        } to fail_with "result should have been initially been 'bar', but was 'string'"
    }
}