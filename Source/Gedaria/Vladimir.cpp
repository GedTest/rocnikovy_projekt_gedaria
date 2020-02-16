// Viktor Zwinger ©2020

#include "Vladimir.h" 
#include "UObject/ConstructorHelpers.h"
#include "PaperFlipbook.h"
#include "GameFramework/Controller.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Components/BoxComponent.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "PaperFlipbookComponent.h"
#include "Components/CapsuleComponent.h"

AVladimir::AVladimir() {
	PrimaryActorTick.bCanEverTick = true;

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
		//second dimension axis lock
		bUseControllerRotationPitch = false;
		bUseControllerRotationRoll = false;
		bUseControllerRotationYaw = true;
	}

	// Box Collision properties
	BoxCollision = CreateDefaultSubobject<UBoxComponent>(TEXT("BoxCollision"));
	if (BoxCollision) {
		BoxCollision->SetupAttachment(GetSprite());
		BoxCollision->RelativeLocation = FVector(30.0f, 0.0f, 0.0f);
		BoxCollision->SetRelativeScale3D(FVector(4.44f, 1.44f, 4.44f));
	}

	//Character movement properties
	CharacterMovement = GetCharacterMovement();
	if (CharacterMovement) {
		CharacterMovement->GravityScale = 2.0f;
		CharacterMovement->AirControl = 1.f;
		CharacterMovement->MaxStepHeight = 700.0f;
		CharacterMovement->JumpZVelocity = 1000.0f;
		CharacterMovement->GetNavAgentPropertiesRef().bCanCrouch = true;		//Crouching, ! important !
		CrouchedEyeHeight = CharacterMovement->CrouchedHalfHeight * 0.80f;		//Crouching
		CharacterMovement->MaxWalkSpeedCrouched = 200.0f;
		CharacterMovement->bUseFlatBaseForFloorChecks = true;
		// Lock Player into XZ axis, that he can't fall of the 2D World
		CharacterMovement->bConstrainToPlane = true;
		CharacterMovement->SetPlaneConstraintNormal(FVector(0.0f, 1.0f, 0.0f));
	}

	// Flipbook references
	static ConstructorHelpers::FObjectFinder<UPaperFlipbook>RunObj(TEXT("PaperFlipbook'/Game/Vladimir/animations/flipbook/Run.Run'"));
	Run = RunObj.Object;
	static ConstructorHelpers::FObjectFinder<UPaperFlipbook>IdleObj(TEXT("PaperFlipbook'/Game/Vladimir/animations/flipbook/Vlad.Vlad'"));
	Idle = IdleObj.Object;
}

void AVladimir::BeginPlay()
{
	Super::BeginPlay();
}

void AVladimir::Tick(float DeltaSeconds)
{
	Super::Tick(DeltaSeconds);
	DeltaTime = DeltaSeconds;
	Position = GetActorLocation();

	UpdateCharacter();
	UE_LOG(LogTemp, Warning, TEXT("Position: %s DeltaTime: %f"),*Position.ToString(), DeltaTime);
}

/*
void AVladimir::SetupPlayerInputComponent(class UInputComponent* InputComponent) {
	Super::SetupPlayerInputComponent(InputComponent);

	if (InputComponent)
	{
		InputComponent->BindAxis("MoveRight", this, &AVladimir::Move);
		InputComponent->BindAction("Jump", EInputEvent::IE_Pressed, this, &AVladimir::JumP);
		// InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
	}		
}*/

void AVladimir::Move(float value)
{
	auto MovingVelocity = CharacterMovement->GetLastUpdateVelocity();
	APawn::ControlInputVector += FVector::ForwardVector * value;

	UPaperFlipbookComponent* CurrentFlipbook = GetSprite();
	UPaperFlipbook* Animation = (MovingVelocity.X != 0.0f) ? Run : Idle;
	if (CurrentFlipbook->GetFlipbook() != Animation) {
		CurrentFlipbook->SetFlipbook(Animation);
	}
}

void AVladimir::JumpZ() 
{
	if (CharacterMovement && CanJumppp) {
		CharacterMovement->Velocity.Z = CharacterMovement->JumpZVelocity;
		CharacterMovement->SetMovementMode(MOVE_Falling);
	}
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
