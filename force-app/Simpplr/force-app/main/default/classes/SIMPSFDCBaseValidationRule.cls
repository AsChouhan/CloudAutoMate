/**
 * OWASP Enterprise Security API (ESAPI)
 * 
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2010 - Salesforce.com
 * 
 * The Apex ESAPI implementation is published by Salesforce.com under the New BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 * 
 * @author Yoel Gluck (securecloud .at. salesforce.com) <a href="http://www.salesforce.com">Salesforce.com</a>
 * @created 2010
 */

/**
 * This is a base class it is only inteneded to help other classes so we don't have the same code in all of them.
 */
public with sharing virtual class SIMPSFDCBaseValidationRule {

	private String typeName = null;
	private boolean allowNull = false;
	
	private SIMPSFDCBaseValidationRule() {
		// prevent use of no-arg constructor
	}
	
	public SIMPSFDCBaseValidationRule( String typeName ) {
		this();
		setTypeName( typeName );
	}
	
    /**
     * {@inheritDoc}
	 */
	public void setAllowNull( boolean flag ) {
		allowNull = flag;
	}

    /**
     * {@inheritDoc}
	 */
	public String getTypeName() {
		return typeName;
	}
	
    /**
     * {@inheritDoc}
	 */
	public void setTypeName( String typeName ) {
		this.typeName = typeName;
	}
	
	public boolean isAllowNull() {
		return allowNull;
	}
}