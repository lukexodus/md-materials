## Rollback Procedure


If issues detected:

1. **Stop deployment**
    
    ``bash
    ./scripts/stop-deployment.sh
    ``
    
2. **Apply rollback migration**
    
    `bash
    supabase migration new rollback_mfa_system
    supabase db push --project-ref production
    ``
    
3. **Revert application code**
    
    ``bash
    ./scripts/deploy-previous-version.sh
    ``
    
4. **Verify rollback**
    
    - Confirm old schema restored
    - Test core functionality
    - Monitor error rates

