<%-- 
    Document   : error.jsp
    Created on : Nov 15, 2011, 1:32:09 AM
    Author     : Vaio
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ page isErrorPage="true" %>

<html>
<head>
    <title>Mini Musical Star - Oops!</title>
</head>
<body bgcolor="fffff2">
    <center>
        <img src="./images/Mini_Musical_Star.jpg" height="250" />
	<div>
        <br>
	<%= "There is a problem submitting your feedback. Please try again later." %><br>
        <%= "Do check if you have entered a valid email address." %><br><br>
        <form>
            <input type="button" value="Back to your feedback form." onClick="javascript: history.go(-1)">
        </form>
	</div>
    </center>
</body>
</html>
