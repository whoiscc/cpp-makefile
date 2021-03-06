#
PROJECT := Server


# build tools
LD := $(CXX)


# build flags
override CFLAGS := -g -Wall -iquote.obj/gen $(CFLAGS)
override CXXFLAGS := -std=c++17 $(CXXFLAGS)
override LDFLAGS := $(LDFLAGS)
define add-CFLAGS
$(foreach src,$(1),$(eval CFLAGS-$(src) += $(2)))
endef
define add-LDFLAGS
$(foreach bin,$(1),$(eval LDFLAGS-$(bin) += $(2)))
endef


d :=
o = .obj/$(d)
# source list
SRCS += \
	$(d)Source/Main.cc
TEST_SRCS += 
$(call add-CFLAGS,$(TEST_SRCS),-I./Source)


# main executable
$(d)$(PROJECT): $(SRCS:%.cc=.obj/%.o)
BINS += $(d)$(PROJECT)
run: $(d)$(PROJECT)
	$(call trace,RUN,$<,./$<)


# test executable and libraries
# apt install libgtest-dev
GTEST_DIR := /usr/src/gtest
GTEST := .obj/gtest/gtest.a
GTEST_MAIN := .obj/gtest/gtest_main.a
GTEST_INTERNAL_SRCS := $(wildcard $(GTEST_DIR)/src/*.cc)
$(call add-CFLAGS,$(GTEST_INTERNAL_SRCS),-pthread -I$(GTEST_DIR) -Wno-missing-field-initializers)
GTEST_OBJS := $(patsubst %.cc,.obj/gtest/%.o,$(notdir $(GTEST_INTERNAL_SRCS)))
$(GTEST_OBJS): .obj/gtest/%.o: $(GTEST_DIR)/src/%.cc
	$(call compilecxx,CXX,)
$(GTEST): .obj/gtest/gtest-all.o
	$(call trace,AR,$@,$(AR) $(ARFLAGS) $@ $^)
$(GTEST_MAIN): .obj/gtest/gtest-all.o .obj/gtest/gtest_main.o
	$(call trace,AR,$@,$(AR) $(ARFLAGS) $@ $^)
$(d)RunTest: $(TEST_SRCS:%.cc=.obj/%.o) $(GTEST_MAIN)
$(call add-LDFLAGS,$(d)RunTest,-pthread)
BINS += $(d)RunTest
.PHONY: test
test: $(d)RunTest
	$(call trace,RUN,$<,./$<)

# include sub-Makefiles


# universal building rule
ifeq ($(V),1)
trace = $(3)
Q =
else
trace = @printf "+ %-6s " $(1) ; echo $(2) ; $(3)
Q = @
endif

DEPFLAGS = -M -MF ${@:.o=.d} -MP -MT $@ -MG
define compilecxx
	@mkdir -p $(dir $@)
	$(call trace,CXX,$<,\
	  $(CXX) -iquote. $(CFLAGS) $(CXXFLAGS) $(CFLAGS-$<) $(DEPFLAGS) -E $<)
	$(Q)$(CXX) -iquote. $(CFLAGS) $(CXXFLAGS) $(CFLAGS-$<) -c -o $@ $<
endef

OBJS := $(SRCS:%.cc=.obj/%.o) $(TEST_SRCS:%.cc=.obj/%.o)
$(OBJS): .obj/%.o: %.cc
	$(call compilecxx)
DEPS := $(OBJS:.o=.d) $(OBJS:.o=-pic.d)
-include $(DEPS)
$(BINS): %:
	$(call trace,LD,$@,$(LD) -o $@ $^ $(LDFLAGS) $(LDFLAGS-$@))


# clean up
.PHONY: clean
clean:
	$(call trace,RM,Bins,rm -f $(BINS))
	$(call trace,RM,Objs,rm -rf .obj)
