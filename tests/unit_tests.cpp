#include <gtest/gtest.h>
#include "math_operations.h"

TEST(AddTests, PositiveNumbers) {
    EXPECT_EQ(add(2, 3), 5);
}

TEST(AddTests, NegativeAndPositive) {
    EXPECT_EQ(add(-4, 4), 0);
}

// Additional example test
TEST(AddTests, Zero) {
    EXPECT_EQ(add(0, 0), 0);
}
