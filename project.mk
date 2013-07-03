
SHARED_LIB_PROJECTS = $(foreach project,$(PROJECTS),$(is_shared_lib))

BUILD_DIR = build

DEPENDS = $(SRCS:.cpp=.d)

getSourceFiles = $(wildcard $(srcFolder)/*.cpp)

getSources = $(foreach srcFolder,$1,$(getSourceFiles))

getSharedLibOutput = $(addsuffix .dylib,$(addprefix build/lib,$(call firstUpper,$(project))))

firstUpper = $(shell echo $1 | perl -pe 's/^(\w)/\u$$1/g')

is_shared_lib = $(if \
		$(filter SHARED_LIB,$($(1)_TYPE)),\
			$(1)\
	)

projectNameFromOutput = $(strip $(foreach project,$(PROJECTS),$(if $(call is_shared_lib,$(project)),\
	$(if $(filter $1,$(call getSharedLibOutput,$(project))),$(project))\
	,"uknown project")))

define DEPENDS_template =
@echo depends!!
$($(1)_DEPENDS): $($(1)_SOURCES)
	mkdir build/$(1)
	@echo getting depends for $^ : $@
endef

define PROJECT_VARS_template
$(1)_OUTPUT = $(if $(call is_shared_lib,$1),$(addsuffix .dylib,$(addprefix build/$(1)/lib,$(call firstUpper,$(1)))))
$(1)_SOURCES = $(call getSources,$($(1)_SOURCES))
$(1)_DEPENDS = $$(addprefix build/,$$(patsubst %.cpp,%.d,$$($(1)_SOURCES)))
endef

define PROJECT_BUILD_template
$($(1)_OUTPUT): $($(1)_DEPENDS)	
	@echo doing project build $(1)
endef

define PROJECT_DEBUG_template
$(1)_DEBUG:	
	@echo $(1) OUTPUT = $($(1)_OUTPUT)
	@echo $(1) SOURCES = $($(1)_SOURCES)	
	@echo $(1) DEPENDS = $($(1)_DEPENDS)
endef

all: $(BUILD_DIR) $(foreach project,$(PROJECTS),$($(project)_OUTPUT))
.PHONY: all

$(foreach project,$(PROJECTS),$(warning making vars for $(project))$(eval $(call PROJECT_VARS_template,$(project))))
$(foreach project,$(PROJECTS),$(warning making depends for $(project))$(eval $(call DEPENDS_template,$(project))))
$(foreach project,$(PROJECTS),$(warning making debug for $(project))$(eval $(call PROJECT_DEBUG_template,$(project))))
$(foreach project,$(PROJECTS),$(warning making build for $(project))$(eval $(call PROJECT_BUILD_template,$(project))))


#build/%/%.d: $(eval PROJECT+=%)%.cpp
#	@echo $(PROJECT)
	#@echo getting depends for $^ : $@
	#$(CC) $(CFLAGS) -MM $^ -MF $@)

debug: $(foreach project,$(PROJECTS),$(project)_DEBUG)

$(BUILD_DIR):
	rm -Rf $(BUILD_DIR)	
	mkdir $(BUILD_DIR)

clean: 
	rm -Rf $(BUILD_DIR)