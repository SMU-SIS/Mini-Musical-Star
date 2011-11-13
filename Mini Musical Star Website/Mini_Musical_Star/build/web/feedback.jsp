<%-- 
    Document   : feedback
    Created on : Oct 6, 2011, 9:18:07 PM
    Author     : Vaio
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ page errorPage="error.jsp" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mini Musical Star</title>
        
        <script>
            function validateForm()
            {
                if((document.feedbackForm.from.value == "") || (document.feedbackForm.subject.value == "") || (document.feedbackForm.message.value == ""))
                    {
                        alert("Please ensure that all fields are filled up.");
                        return false;
                    }
                        
		if((document.feedbackForm.from.value.indexOf("@") == -1) || (document.feedbackForm.from.value.indexOf(".") == -1))
                    {
                        alert("Please give a valid email.");
                        document.feedbackForm.from.focus();
                        return false;
                    }
            }
        </script>
    </head>
    <body bgcolor="fffff2">
    <center>
        <img src="./images/Mini_Musical_Star.jpg" height="250" />
        <p>
            <a href="./index.jsp"><img src="./images/home.png" border="0" /></a>
            <a href="./feedback.jsp"><img src="./images/feedback.png" border="0" /></a>
        </p>
    <div>
	<form name="feedbackForm" action="processing.jsp" method="post" onSubmit="return validateForm()">
        
        <table width="350">
        <tr width="100">
            <td>Name:</td>
            <td><input type="text" name="subject" class="std"></input></br></td>
        </tr>
        <tr width="100">
            <td>Email: </td>
            <td><input type="text" name="from" class="std"></input></br></td>
        </tr>
        <tr width="100">
            <td>Comments:</td>
            <td><textarea rows="8" cols="50" name="message"></textarea></td>
            
        </tr>
        </table>

	<input type="submit" value="Send"></input>
	</form>
</div>
    </center>
    </body>
</html>
