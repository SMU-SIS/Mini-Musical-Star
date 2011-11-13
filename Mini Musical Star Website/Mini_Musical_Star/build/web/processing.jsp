<%-- 
    Document   : processing
    Created on : Nov 14, 2011, 7:58:55 PM
    Author     : Vaio
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ page errorPage="error.jsp" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mini Musical Star - Feedback</title>
    </head>
<body>
	<jsp:useBean id="mailer" class="com.stardeveloper.bean.test.MailerBean">
		<jsp:setProperty name="mailer" property="*"/>
		<% mailer.sendMail(); %>
	</jsp:useBean>
        <%
            response.sendRedirect("/processed.jsp");
        %>
    </body>
</html>
