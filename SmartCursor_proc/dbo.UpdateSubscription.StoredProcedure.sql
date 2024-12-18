USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[UpdateSubscription]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create     PROCEDURE [dbo].[UpdateSubscription]
    @CompanyId bigint
AS
BEGIN
    DECLARE @OldSubscriptionId uniqueidentifier;
    DECLARE @NewSubscriptionId uniqueidentifier;
    DECLARE @LicensesUsed int;

    -- Get the old and new subscription IDs
    SELECT @OldSubscriptionId = id FROM License.Subscription  WHERE SubscriptionName LIKE '%Accounting with Single Entity%'  AND CompanyId = @CompanyId;

    SELECT @NewSubscriptionId = id FROM License.Subscription  WHERE SubscriptionName LIKE '%Accounting with Multi Entity%' AND CompanyId = @CompanyId;

    -- Check if old subscription exists
    IF @OldSubscriptionId IS NOT NULL
    BEGIN
        -- Check if new subscription exists
        IF @NewSubscriptionId IS NOT NULL
        BEGIN
            -- Update Common.CompanyUserSubscription
            IF EXISTS ( SELECT * FROM Common.CompanyUserSubscription  WHERE CompanyId = @CompanyId AND SubscriptionId = @OldSubscriptionId)
            BEGIN
			                SELECT @LicensesUsed = COUNT(*) FROM Common.CompanyUserSubscription  WHERE CompanyId = @CompanyId AND SubscriptionId = @OldSubscriptionId;
							select @LicensesUsed
                UPDATE Common.CompanyUserSubscription SET SubscriptionId = @NewSubscriptionId WHERE CompanyId = @CompanyId AND SubscriptionId = @OldSubscriptionId;
                

            END

            -- Update Auth.RoleNew
            IF EXISTS (SELECT * FROM Auth.RoleNew WHERE CompanyId = @CompanyId AND SubscriptionId = @OldSubscriptionId)
            BEGIN UPDATE Auth.RoleNew  SET SubscriptionId = @NewSubscriptionId WHERE CompanyId = @CompanyId AND SubscriptionId = @OldSubscriptionId;
            END

            -- Update License.Subscription
            IF EXISTS (SELECT * FROM Auth.RoleNew  WHERE CompanyId = @CompanyId AND SubscriptionId = @NewSubscriptionId )
            BEGIN
                UPDATE License.Subscription  SET LicensesUsed = 0, Status = 4 WHERE CompanyId = @CompanyId AND Id = @OldSubscriptionId;
                      
                  IF @LicensesUsed IS NOT NULL
                    BEGIN
                        UPDATE License.Subscription
                        SET LicensesUsed = @LicensesUsed
                        WHERE CompanyId = @CompanyId AND Id = @NewSubscriptionId;
                    END
            END
        END
    END
END
GO
