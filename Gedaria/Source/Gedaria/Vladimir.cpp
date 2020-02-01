// Viktor Zwinger ©2020

#include "Vladimir.h"
#include "PaperFlipbook.h"
#include "GameFramework/Controller.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Components/BoxComponent.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "PaperFlipbookComponent.h"
#include "Components/CapsuleComponent.h"

AVladimir::AVladimir() {
	// Capsule properties
	GetCapsuleComponent()->SetCapsuleHalfHeight(96.0f);
	GetCapsuleComponent()->SetCapsuleRadius(40.0f);

	// Sprite properties
	GetSprite()->SetRelativeScale3D(FVector(0.125f, 0.125f, 0.125f));

	// Set SpringArm properties
	SpringArm = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm"));
	if (SpringArm) {
		SpringArm->SetupAttachment(RootComponent);
		SpringArm->TargetArmLength = 500;
		SpringArm->bAbsoluteRotation = true;
		SpringArm->RelativeRotation = FRotator(0.0f, -90.0f, 0.0f);
		SpringArm->SocketOffset = FVector(0.0f, 0.0f, 75.0f);
	}

	// Camera properties
	Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera"));
	if (Camera) {
		Camera->SetupAttachment(SpringArm);
		Camera->SetFieldOfView(110.0f);
	}

	// Box Collision properties
	BoxCollision = CreateDefaultSubobject<UBoxComponent>(TEXT("BoxCollision"));
	if (BoxCollision) {
		BoxCollision->SetupAttachment(GetSprite());
		BoxCollision->RelativeLocation = FVector(30.0f, 0.0f, 0.0f);
		BoxCollision->SetRelativeScale3D(FVector(4.44f, 1.44f, 4.44f));
	}

	//Character movement properties
	GetCharacterMovement()->GravityScale = 2.0f;
	GetCharacterMovement()->MaxStepHeight = 700.0f;
	GetCharacterMovement()->JumpZVelocity = 1000.0f;
	GetCharacterMovement()->GetNavAgentPropertiesRef().bCanCrouch = true;		//Crouching, ! important !
	CrouchedEyeHeight = GetCharacterMovement()->CrouchedHalfHeight * 0.80f;		//Crouching
	GetCharacterMovement()->MaxWalkSpeedCrouched = 200.0f;
}

void AVladimir::BeginPlay()
{
	Super::BeginPlay();
}

void AVladimir::Tick(float DeltaSeconds)
{
	Super::Tick(DeltaSeconds);
	UpdateCharacter();
}

void AVladimir::SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) {

	if (PlayerInputComponent)
	{
		PlayerInputComponent->BindAxis("MoveRight", this, &AVladimir::Move);
	}		
}


void AVladimir::Move(float value)
{
/*
	auto CurrentFlipbok = GetSprite();
	CurrentFlipbok->SetFlipbook(Run);
*/
	APawn::ControlInputVector += FVector::ForwardVector * value;
}

void AVladimir::UpdateCharacter()
{
	const FVector PlayerVelocity = GetVelocity();
	float TravelDirection = PlayerVelocity.X;

	if (!ensure(Controller)) { return; }
	if (TravelDirection < 0.0f) {
		Controller->SetControlRotation(FRotator(0.0f, 180.0f, 0.0f));
	}
	else if (TravelDirection > 0.0f) {
		Controller->SetControlRotation(FRotator(0.0f, 0.0f, 0.0f));
	}
}
