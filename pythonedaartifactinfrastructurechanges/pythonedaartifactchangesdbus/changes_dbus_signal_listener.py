"""
pythonedaartifactinfrastructurepyprojectversioning/pythonedaartifactpyprojectversioningdbus/pyproject_versioning_dbus_signal_listener.py

This file defines the PyprojectVersioningDbusSignalListener class.

Copyright (C) 2023-today rydnr's pythoneda-artifact-infrastructure/pyproject-versioning

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""
from pythoneda.event import Event
from pythonedaartifacteventversioning.version_created import VersionCreated
from pythonedaartifacteventinfrastructureversioning.pythonedaartifacteventversioningdbus.dbus_version_created import DbusVersionCreated
from pythonedainfrastructure.pythonedadbus.dbus_signal_listener import DbusSignalListener
from dbus_next import BusType, Message
from typing import Dict

class PyprojectVersioningDbusSignalListener(DbusSignalListener):

    """
    A Port that listens to Versioning-relevant d-bus signals.

    Class name: PyprojectVersioningDbusSignalListener

    Responsibilities:
        - Connect to d-bus.
        - Listen to signals relevant to the Versioning domain.

    Collaborators:
        - PythonEDA: Receives relevant domain events.
    """

    def __init__(self):
        """
        Creates a new PyprojectVersioningDbusSignalListener instance.
        """
        super().__init__()

    def signal_receivers(self, app) -> Dict:
        """
        Retrieves the configured signal receivers.
        :param app: The PythonEDA instance.
        :type app: PythonEDA from pythonedaapplication.pythoneda
        :return: A dictionary with the signal name as key, and the tuple interface and bus type as the value.
        :rtype: Dict
        """
        result = {}
        key = self.fqdn_key(VersionCreated)
        result[key] = [
            DbusVersionCreated, BusType.SYSTEM
        ]
        return result

    def parse_pythonedaartifactversioning_VersionCreated(self, message: Message) -> VersionCreated:
        """
        Parses given d-bus message containing a VersionCreated event.
        :param message: The message.
        :type message: dbus_next.Message
        :return: The TagCreated event.
        :rtype: pythonedaartifacteventversioning.version_created.VersionCreated
        """
        return DbusVersionCreated.parse_pythonedaartifactversioning_VersionCreated(message)

    async def listen_pythonedaartifactversioning_VersionCreated(self, event: VersionCreated):
        """
        Gets notified when a VersionCreated event occurs.
        :param event: The VersionCreated event.
        :type event: pythonedaartifacteventversioning.version_created.VersionCreated
        """
        await self.app.accept(event)
