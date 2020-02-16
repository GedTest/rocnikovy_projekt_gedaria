// Viktor Zwinger ©2020

#pragma once

#include "CoreMinimal.h"
#include "PaperCharacter.h"
#include "Vladimir.generated.h"

// Forward Declaration
class UCameraComponent;
class USpringArmComponent;
class UBoxComponent;
class UPaperFlipbook;

/**
 * 
 */
UCLASS()
class GEDARIA_API AVladimir : public APaperCharacter
{
	GENERATED_BODY()
	
public:
	// Creates default value to its components
	AVladimir();

	// Called when the game starts or when spawned
	void BeginPlay() override;

	UFUNCTION(BlueprintCallable, Category = "Movement")
	void Move(float value);

	UFUNCTION(BlueprintCallable, Category = "Movement")
	void JumpZ();
	
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Jump")
	bool CanJumppp = true;
	
	float DeltaTime = 0;		//Delta Time, Elapsed Time, difference between last frame

private:
	// Called every frame
	void Tick(float DeltaSeconds) override;

	// Axis mapping function

	// void SetupPlayerInputComponent(class UInputComponent* InputComponent) override;
	void UpdateCharacter();

	USpringArmComponent* SpringArm = nullptr;
	UCameraComponent* Camera = nullptr;
	UBoxComponent* BoxCollision = nullptr;

	UPaperFlipbook* Run = nullptr;
	UPaperFlipbook* Idle = nullptr;

	FVector Position;	// Find PlayerPosition
	UCharacterMovementComponent* CharacterMovement = nullptr;
};
