// ==UserScript==
// @name        WinSCP SFTP URL for Amazon EC2
// @namespace   https://winscp.net/
// @author      WinSCP
// @homepage    https://winscp.net/eng/docs/guide_injecting_sftp_ftp_url_to_page
// @description Adds an "Open in WinSCP" link next to "Public DNS" field on Instances page of Amazon EC2 management console
// @include     https://*console.aws.amazon.com/*
// @icon        https://winscp.net/pad/winscp.png
// @version     1.0
// @grant       none
// @require     https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js
// ==/UserScript==

setInterval(
  function() {
    waitForHostNameElements();
  },
  500
);

function waitForHostNameElements() {
  var targetNodes = $('span:contains("Public DNS:")');

  if (targetNodes && targetNodes.length > 0) {
    targetNodes.each(function() {
      // link not added yet
      if ($(this).html().indexOf('sftp://') < 1) {
        // Retrieve hostname AWS connect ec2-user@ec2-52-57-114-147.eu-central-1.compute.amazonaws.com
        var hostname = "ec2-52-57-114-147.eu-central-1.compute.amazonaws.com";
        //var hostname = $(this).text().replace("Public DNS:", "").trim();
        // Change the username if needed
        var username = "ec2-user";
        $(this).append(' &ndash; <a href="sftp://' + username + '@' + hostname + '/">Open in WinSCP</a>');
      }
    });
  }
}
