 // Fill out your copyright notice in the Description page of Project Settings.

#include "MyPaperCharacter.h"

AMyPaperCharacter::AMyPaperCharacter() {
	//second dimension axis lock
	bUseControllerRotationPitch = false;
	bUseControllerRotationRoll = false;
	bUseControllerRotationYaw = true;
	PrimaryActorTick.bCanEverTick = true;

	SpringArm = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm"));
	Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera"));
	Box = CreateDefaultSubobject<UBoxComponent>(TEXT("Box"));
	Arrow1 = CreateDefaultSubobject<UArrowComponent>(TEXT("Arrow1"));

	//Capsule properties
	GetCapsuleComponent()->SetCapsuleHalfHeight(96.0f);
	GetCapsuleComponent()->SetCapsuleRadius(40.0f);
	
	//Sprite properties
	this->GetSprite()->SetRelativeScale3D(FVector(0.44f, 0.44f, 0.44f));
	//this->GetSprite()->SetFlipbook(Flipbook);		//not working

	//Arrow1 properties
	Arrow1->SetupAttachment(GetSprite());
	Arrow1->SetRelativeLocation(FVector(100.0f, 0.0f, -25.0f));
	
	//SpringArm properties
	SpringArm->SetupAttachment(RootComponent);
	SpringArm->TargetArmLength = 500;
	SpringArm->bAbsoluteRotation = true;
	SpringArm->RelativeRotation = FRotator(0.0f, -90.0f, 0.0f);
	SpringArm->SocketOffset = FVector(0.0f, 0.0f, 75.0f);

	//Camera properties
	Camera->SetupAttachment(SpringArm);
	Camera->SetFieldOfView(110.0f);

	//box properties
	Box->SetupAttachment(GetSprite());
	Box->RelativeLocation = FVector(30.0f, 0.0f, 0.0f);
	Box->SetRelativeScale3D(FVector(4.44f, 1.44f, 4.44f));

	//Character movement properties
	GetCharacterMovement()->GravityScale = 2.0f;
	GetCharacterMovement()->MaxStepHeight = 700.0f;
	GetCharacterMovement()->JumpZVelocity = 1000.0f;
	GetCharacterMovement()->GetNavAgentPropertiesRef().bCanCrouch = true;		//Crouching, ! important !
	CrouchedEyeHeight = GetCharacterMovement()->CrouchedHalfHeight * 0.80f;		//Crouching
	GetCharacterMovement()->MaxWalkSpeedCrouched = 200.0f;						//Crouching
}

// Called when the game starts or when spawned
void AMyPaperCharacter::BeginPlay()
{
	Super::BeginPlay();

}

// Called every frame
void AMyPaperCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
	UpdateCharacter();

}

//Update function
void AMyPaperCharacter::UpdateCharacter() {
	const FVector PlayerVelocity = GetVelocity();
	float TravelDirection = PlayerVelocity.X;
	// Set the rotation so that the character faces his direction of travel.
	if (Controller != nullptr)
	{
		if (TravelDirection < 0.0f)
		{
			Controller->SetControlRotation(FRotator(0.0, 180.0f, 0.0f));
		}
		else if (TravelDirection > 0.0f)
		{
			Controller->SetControlRotation(FRotator(0.0f, 0.0f, 0.0f));
		}
	}
} 

//Axis Binding
void AMyPaperCharacter::SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent){

		if (PlayerInputComponent)
		{
			PlayerInputComponent->BindAxis("MoveRight", this, &AMyPaperCharacter::MoveX);
			PlayerInputComponent->BindAction("Jump", EInputEvent::IE_Pressed, this, &AMyPaperCharacter::Jump);	
			
			
			FInputActionBinding ActionBindingParam;
			ActionBindingParam.GetActionName() = FName("Crouch");
			ActionBindingParam.KeyEvent = IE_Pressed;

			FInputActionHandlerSignature ActionHandler;
			ActionHandler.BindUFunction(this, FName("ChangeCrouch"));

			ActionBindingParam.ActionDelegate = ActionHandler;
			InputComponent->AddActionBinding(ActionBindingParam);

			PlayerInputComponent->BindAction("Crouch", EInputEvent::IE_Pressed, this, &AMyPaperCharacter::ChangeCrouch);
		}
}

//Movement in X Axis
void AMyPaperCharacter::MoveX(float value) {
					    //     Direction	   , * 1or-1 from input
	//AddMovementInput(FVector::ForwardVector, value);
	//UPawnMovementComponent* MovementComponent = GetMovementComponent();
	//MovementComponent->AddInputVector(FVector::ForwardVector * value);
	APawn::ControlInputVector += FVector::ForwardVector * value;					//Acceleration = Direction * value(1 or -1)
}

void AMyPaperCharacter::ChangeCrouch() {
	if (CanCrouch() == true) {
		Crouch();
	}
	else {
		UnCrouch();
	}
}
