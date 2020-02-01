// Copyright 1998-2018 Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
#include "Gedaria/Vladimir.h"
#ifdef _MSC_VER
#pragma warning (push)
#pragma warning (disable : 4883)
#endif
PRAGMA_DISABLE_DEPRECATION_WARNINGS
void EmptyLinkFunctionForGeneratedCodeVladimir() {}
// Cross Module References
	GEDARIA_API UClass* Z_Construct_UClass_AVladimir_NoRegister();
	GEDARIA_API UClass* Z_Construct_UClass_AVladimir();
	PAPER2D_API UClass* Z_Construct_UClass_APaperCharacter();
	UPackage* Z_Construct_UPackage__Script_Gedaria();
// End Cross Module References
	void AVladimir::StaticRegisterNativesAVladimir()
	{
	}
	UClass* Z_Construct_UClass_AVladimir_NoRegister()
	{
		return AVladimir::StaticClass();
	}
	struct Z_Construct_UClass_AVladimir_Statics
	{
		static UObject* (*const DependentSingletons[])();
#if WITH_METADATA
		static const UE4CodeGen_Private::FMetaDataPairParam Class_MetaDataParams[];
#endif
		static const FCppClassTypeInfoStatic StaticCppClassTypeInfo;
		static const UE4CodeGen_Private::FClassParams ClassParams;
	};
	UObject* (*const Z_Construct_UClass_AVladimir_Statics::DependentSingletons[])() = {
		(UObject* (*)())Z_Construct_UClass_APaperCharacter,
		(UObject* (*)())Z_Construct_UPackage__Script_Gedaria,
	};
#if WITH_METADATA
	const UE4CodeGen_Private::FMetaDataPairParam Z_Construct_UClass_AVladimir_Statics::Class_MetaDataParams[] = {
		{ "HideCategories", "Navigation" },
		{ "IncludePath", "Vladimir.h" },
		{ "ModuleRelativePath", "Vladimir.h" },
	};
#endif
	const FCppClassTypeInfoStatic Z_Construct_UClass_AVladimir_Statics::StaticCppClassTypeInfo = {
		TCppClassTypeTraits<AVladimir>::IsAbstract,
	};
	const UE4CodeGen_Private::FClassParams Z_Construct_UClass_AVladimir_Statics::ClassParams = {
		&AVladimir::StaticClass,
		DependentSingletons, ARRAY_COUNT(DependentSingletons),
		0x009000A0u,
		nullptr, 0,
		nullptr, 0,
		nullptr,
		&StaticCppClassTypeInfo,
		nullptr, 0,
		METADATA_PARAMS(Z_Construct_UClass_AVladimir_Statics::Class_MetaDataParams, ARRAY_COUNT(Z_Construct_UClass_AVladimir_Statics::Class_MetaDataParams))
	};
	UClass* Z_Construct_UClass_AVladimir()
	{
		static UClass* OuterClass = nullptr;
		if (!OuterClass)
		{
			UE4CodeGen_Private::ConstructUClass(OuterClass, Z_Construct_UClass_AVladimir_Statics::ClassParams);
		}
		return OuterClass;
	}
	IMPLEMENT_CLASS(AVladimir, 1007966950);
	static FCompiledInDefer Z_CompiledInDefer_UClass_AVladimir(Z_Construct_UClass_AVladimir, &AVladimir::StaticClass, TEXT("/Script/Gedaria"), TEXT("AVladimir"), false, nullptr, nullptr, nullptr);
	DEFINE_VTABLE_PTR_HELPER_CTOR(AVladimir);
PRAGMA_ENABLE_DEPRECATION_WARNINGS
#ifdef _MSC_VER
#pragma warning (pop)
#endif
