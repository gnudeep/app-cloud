--
--  Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
--
--    WSO2 Inc. licenses this file to you under the Apache License,
--    Version 2.0 (the "License"); you may not use this file except
--    in compliance with the License.
--    You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--    Unless required by applicable law or agreed to in writing,
--    software distributed under the License is distributed on an
--    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
--    KIND, either express or implied.  See the License for the
--    specific language governing permissions and limitations
--    under the License.
--

-- -----------------------------------------------------------
-- Updates to the AC_APP_TYPE
-- -----------------------------------------------------------
UPDATE `AC_APP_TYPE` SET `description` = 'Allows you to deploy an integration scenario developed by Ballerina.' WHERE `id` = 8;
UPDATE `AC_APP_TYPE` SET `description` = 'Allows you to deploy Java Microservices (MSF4J)' WHERE `id` = 2;

-- update ballerina composer container spec
UPDATE `AC_RUNTIME_CONTAINER_SPECIFICATIONS` SET `CON_SPEC_ID` = 4 WHERE `id` = 21;

