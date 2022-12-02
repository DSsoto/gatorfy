#include <vector>

#include  <gtest/gtest.h>
#include <fmt/format.h>

TEST(DummyTest, BlahTestSuite){
    EXPECT_TRUE(true);
    // EXPECT_TRUE(false);
}

int main(int argc, char** argv) {
    fmt::print("Hello World\n");
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
