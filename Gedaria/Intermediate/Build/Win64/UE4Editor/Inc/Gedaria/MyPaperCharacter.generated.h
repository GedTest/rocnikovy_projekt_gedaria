// Copyright 1998-2018 Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/ObjectMacros.h"
#include "UObject/ScriptMacros.h"

PRAGMA_DISABLE_DEPRECATION_WARNINGS
#ifdef GEDARIA_MyPaperCharacter_generated_h
#error "MyPaperCharacter.generated.h already included, missing '#pragma once' in MyPaperCharacter.h"
#endif
#define GEDARIA_MyPaperCharacter_generated_h

#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_RPC_WRAPPERS \
 \
	DECLARE_FUNCTION(execChangeCrouch) \
	{ \
		P_FINISH; \
		P_NATIVE_BEGIN; \
		P_THIS->ChangeCrouch(); \
		P_NATIVE_END; \
	}


#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_RPC_WRAPPERS_NO_PURE_DECLS \
 \
	DECLARE_FUNCTION(execChangeCrouch) \
	{ \
		P_FINISH; \
		P_NATIVE_BEGIN; \
		P_THIS->ChangeCrouch(); \
		P_NATIVE_END; \
	}


#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_INCLASS_NO_PURE_DECLS \
private: \
	static void StaticRegisterNativesAMyPaperCharacter(); \
	friend struct Z_Construct_UClass_AMyPaperCharacter_Statics; \
public: \
	DECLARE_CLASS(AMyPaperCharacter, APaperCharacter, COMPILED_IN_FLAGS(0), CASTCLASS_None, TEXT("/Script/Gedaria"), NO_API) \
	DECLARE_SERIALIZER(AMyPaperCharacter)


#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_INCLASS \
private: \
	static void StaticRegisterNativesAMyPaperCharacter(); \
	friend struct Z_Construct_UClass_AMyPaperCharacter_Statics; \
public: \
	DECLARE_CLASS(AMyPaperCharacter, APaperCharacter, COMPILED_IN_FLAGS(0), CASTCLASS_None, TEXT("/Script/Gedaria"), NO_API) \
	DECLARE_SERIALIZER(AMyPaperCharacter)


#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_STANDARD_CONSTRUCTORS \
	/** Standard constructor, called after all reflected properties have been initialized */ \
	NO_API AMyPaperCharacter(const FObjectInitializer& ObjectInitializer); \
	DEFINE_DEFAULT_OBJECT_INITIALIZER_CONSTRUCTOR_CALL(AMyPaperCharacter) \
	DECLARE_VTABLE_PTR_HELPER_CTOR(NO_API, AMyPaperCharacter); \
DEFINE_VTABLE_PTR_HELPER_CTOR_CALLER(AMyPaperCharacter); \
private: \
	/** Private move- and copy-constructors, should never be used */ \
	NO_API AMyPaperCharacter(AMyPaperCharacter&&); \
	NO_API AMyPaperCharacter(const AMyPaperCharacter&); \
public:


#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_ENHANCED_CONSTRUCTORS \
private: \
	/** Private move- and copy-constructors, should never be used */ \
	NO_API AMyPaperCharacter(AMyPaperCharacter&&); \
	NO_API AMyPaperCharacter(const AMyPaperCharacter&); \
public: \
	DECLARE_VTABLE_PTR_HELPER_CTOR(NO_API, AMyPaperCharacter); \
DEFINE_VTABLE_PTR_HELPER_CTOR_CALLER(AMyPaperCharacter); \
	DEFINE_DEFAULT_CONSTRUCTOR_CALL(AMyPaperCharacter)


#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_PRIVATE_PROPERTY_OFFSET
#define Gedaria_Source_Gedaria_MyPaperCharacter_h_26_PROLOG
#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_GENERATED_BODY_LEGACY \
PRAGMA_DISABLE_DEPRECATION_WARNINGS \
public: \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_PRIVATE_PROPERTY_OFFSET \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_RPC_WRAPPERS \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_INCLASS \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_STANDARD_CONSTRUCTORS \
public: \
PRAGMA_ENABLE_DEPRECATION_WARNINGS


#define Gedaria_Source_Gedaria_MyPaperCharacter_h_29_GENERATED_BODY \
PRAGMA_DISABLE_DEPRECATION_WARNINGS \
public: \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_PRIVATE_PROPERTY_OFFSET \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_RPC_WRAPPERS_NO_PURE_DECLS \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_INCLASS_NO_PURE_DECLS \
	Gedaria_Source_Gedaria_MyPaperCharacter_h_29_ENHANCED_CONSTRUCTORS \
private: \
PRAGMA_ENABLE_DEPRECATION_WARNINGS


#undef CURRENT_FILE_ID
#define CURRENT_FILE_ID Gedaria_Source_Gedaria_MyPaperCharacter_h


PRAGMA_ENABLE_DEPRECATION_WARNINGS
