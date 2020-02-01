// Copyright 1998-2018 Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
#include "Gedaria/VladSpringArmComponent.h"
#ifdef _MSC_VER
#pragma warning (push)
#pragma warning (disable : 4883)
#endif
PRAGMA_DISABLE_DEPRECATION_WARNINGS
void EmptyLinkFunctionForGeneratedCodeVladSpringArmComponent() {}
// Cross Module References
	GEDARIA_API UClass* Z_Construct_UClass_UVladSpringArmComponent_NoRegister();
	GEDARIA_API UClass* Z_Construct_UClass_UVladSpringArmComponent();
	ENGINE_API UClass* Z_Construct_UClass_USpringArmComponent();
	UPackage* Z_Construct_UPackage__Script_Gedaria();
// End Cross Module References
	void UVladSpringArmComponent::StaticRegisterNativesUVladSpringArmComponent()
	{
	}
	UClass* Z_Construct_UClass_UVladSpringArmComponent_NoRegister()
	{
		return UVladSpringArmComponent::StaticClass();
	}
	struct Z_Construct_UClass_UVladSpringArmComponent_Statics
	{
		static UObject* (*const DependentSingletons[])();
#if WITH_METADATA
		static const UE4CodeGen_Private::FMetaDataPairParam Class_MetaDataParams[];
#endif
		static const FCppClassTypeInfoStatic StaticCppClassTypeInfo;
		static const UE4CodeGen_Private::FClassParams ClassParams;
	};
	UObject* (*const Z_Construct_UClass_UVladSpringArmComponent_Statics::DependentSingletons[])() = {
		(UObject* (*)())Z_Construct_UClass_USpringArmComponent,
		(UObject* (*)())Z_Construct_UPackage__Script_Gedaria,
	};
#if WITH_METADATA
	const UE4CodeGen_Private::FMetaDataPairParam Z_Construct_UClass_UVladSpringArmComponent_Statics::Class_MetaDataParams[] = {
		{ "BlueprintSpawnableComponent", "" },
		{ "HideCategories", "Mobility Trigger PhysicsVolume" },
		{ "IncludePath", "VladSpringArmComponent.h" },
		{ "ModuleRelativePath", "VladSpringArmComponent.h" },
	};
#endif
	const FCppClassTypeInfoStatic Z_Construct_UClass_UVladSpringArmComponent_Statics::StaticCppClassTypeInfo = {
		TCppClassTypeTraits<UVladSpringArmComponent>::IsAbstract,
	};
	const UE4CodeGen_Private::FClassParams Z_Construct_UClass_UVladSpringArmComponent_Statics::ClassParams = {
		&UVladSpringArmComponent::StaticClass,
		DependentSingletons, ARRAY_COUNT(DependentSingletons),
		0x00B000A4u,
		nullptr, 0,
		nullptr, 0,
		"Engine",
		&StaticCppClassTypeInfo,
		nullptr, 0,
		METADATA_PARAMS(Z_Construct_UClass_UVladSpringArmComponent_Statics::Class_MetaDataParams, ARRAY_COUNT(Z_Construct_UClass_UVladSpringArmComponent_Statics::Class_MetaDataParams))
	};
	UClass* Z_Construct_UClass_UVladSpringArmComponent()
	{
		static UClass* OuterClass = nullptr;
		if (!OuterClass)
		{
			UE4CodeGen_Private::ConstructUClass(OuterClass, Z_Construct_UClass_UVladSpringArmComponent_Statics::ClassParams);
		}
		return OuterClass;
	}
	IMPLEMENT_CLASS(UVladSpringArmComponent, 2985585481);
	static FCompiledInDefer Z_CompiledInDefer_UClass_UVladSpringArmComponent(Z_Construct_UClass_UVladSpringArmComponent, &UVladSpringArmComponent::StaticClass, TEXT("/Script/Gedaria"), TEXT("UVladSpringArmComponent"), false, nullptr, nullptr, nullptr);
	DEFINE_VTABLE_PTR_HELPER_CTOR(UVladSpringArmComponent);
PRAGMA_ENABLE_DEPRECATION_WARNINGS
#ifdef _MSC_VER
#pragma warning (pop)
#endif
