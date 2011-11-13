/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Vaio
 */
package com.stardeveloper.bean.test;

import java.io.*;
import java.util.*;
import javax.mail.*;
import javax.mail.event.*;
import javax.mail.internet.*;

public final class MailerBean extends Object implements Serializable {
	
	/* Bean Properties */
	//private String to = null;
	private String from = null;
	private String subject = null;
	private String message = null;
	public static Properties props = null;
	public static Session session = null;

	static {
		/*	Setting Properties for STMP host */
		props = System.getProperties();
		props.put("mail.smtp.host", "mail.yourisp.com");
		session = Session.getDefaultInstance(props, null);
	}
	/* Setter Methods */
        /*
        public void setTo(String to){
            this.to = to;
        }   
         */

	public void setFrom(String from) {
		this.from = from;
	}

	public void setSubject(String subject) {
		this.subject = "User " + subject + " MMS Feedback";
	}

	public void setMessage(String message) {
		this.message = message;
	}
	/* Sends Email */
	public void sendMail() throws Exception {
		if(!this.everythingIsSet())
			throw new Exception("Could not send email.");
		try {
			MimeMessage message = new MimeMessage(session);
			message.setRecipient(Message.RecipientType.TO, 
				new InternetAddress("minimusicalstar@gmail.com"));
			message.setFrom(new InternetAddress(this.from));
			message.setSubject(this.subject);
			message.setText(this.message);
			Transport.send(message);
		} catch (MessagingException e) {
			throw new Exception(e.getMessage());
		}
	}

	/* Checks whether all properties have been set or not */
	private boolean everythingIsSet() {
		if((this.from == null) || 
		   (this.subject == null) || (this.message == null))
			return false;

		if((this.from.indexOf("@") == -1) ||
			(this.from.indexOf(".") == -1))
			return false;

		return true;
	}
}
