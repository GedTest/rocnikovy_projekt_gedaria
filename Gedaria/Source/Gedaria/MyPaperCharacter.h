// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "PaperCharacter.h"
#include "GameFramework/SpringArmComponent.h"
#include "Components/BoxComponent.h"
#include "Components/ArrowComponent.h"
#include "PaperFlipbook.h"
#include "PaperFlipbookComponent.h"
#include "Components/CapsuleComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/Controller.h"
#include "Components/InputComponent.h"
#include "Camera/CameraComponent.h"
#include "Math/Vector.h"

#include "Engine/Engine.h"

#include "MyPaperCharacter.generated.h"

/**
 * 
 */
UCLASS()
class GEDARIA_API AMyPaperCharacter : public APaperCharacter
{
	GENERATED_BODY()
	
public:
	AMyPaperCharacter();
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

	// Called every frame
	virtual void Tick(float DeltaSeconds) override;
	
	//Axis mapping function
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

	void MoveX(float value);

	UFUNCTION()
		void ChangeCrouch();

	void UpdateCharacter();
	float CrouchedEyeHeight;

public:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Default")
		UArrowComponent* Arrow1;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
		USpringArmComponent* SpringArm;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
		UCameraComponent* Camera;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Default")
		UBoxComponent* Box;

	//UPROPERTY(EditAnywhere, BlueprintReadWrite);
	//int Health;
};
