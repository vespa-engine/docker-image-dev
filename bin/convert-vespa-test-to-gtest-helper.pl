#!/usr/bin/env perl
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Usage is still somewhat rough:
# $ convert-vespa-test-to-gtest-helper.pl < some_test.cpp > foo
# $ mv foo some_test.cpp
# Edit CMakeLists.txt and add GTest::gtest as a dependency for the test if not already
# a direct or indirect dependency.
# Edit some_test.cpp to complete any other changes needed for it to work with gtest.

while (<STDIN>) {
    chomp;
    s/^#include <vespa\/vespalib\/testkit\/test_kit.h>/#include <vespa\/vespalib\/gtest\/gtest.h>/;
    s/\bEXPECT_EQUAL\(/EXPECT_EQ(/;
    s/\bEXPECT_NOT_EQUAL\(/EXPECT_NE(/;
    s/\bEXPECT_LESS\(/EXPECT_LT(/;
    s/\bEXPECT_LESS_EQUAL\(/EXPECT_LE(/;
    s/\bEXPECT_GREATER\(/EXPECT_GT(/;
    s/\bEXPECT_GREATER_EQUAL\(/EXPECT_GE(/;
    s/\bEXPECT_APPROX\(/EXPECT_NEAR(/;
    s/\bASSERT_EQUAL\(/ASSERT_EQ(/;
    s/\bASSERT_NOT_EQUAL\(/ASSERT_NE(/;
    s/\bASSERT_LESS\(/ASSERT_LT(/;
    s/\bASSERT_LESS_EQUAL\(/ASSERT_LE(/;
    s/\bASSERT_GREATER\(/ASSERT_GT(/;
    s/\bASSERT_GREATER_EQUAL\(/ASSERT_GE(/;
    s/\bASSERT_APPROX\(/ASSERT_NEAR(/;
    s/TEST_MAIN\(\) \{ TEST_RUN_ALL\(\); \}/GTEST_MAIN_RUN_ALL_TESTS()/;
    if ( m/(TEST(_F|_FF|_FFF|_FFFF|_FFFFF|_MT|_MT_F|_MT_FF|_MT_FFF|_MT_FFFF|_MT_FFFFF)?)\(\"([^"]*)\"/ ) {
	$before = $`;
	$after = $';
	$prefix = $1;
	$name = $3;
	$name =~ s/ /_/g;
	print "$before$prefix(UnnamedTest, $name$after\n";
	next;
    }
    print "$_\n";
}
