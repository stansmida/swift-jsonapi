import JSONAPI
import XCTest

typealias SimpleDocument<Data, Included> = Document<Data, Never, Never, Never, Never, Included, Never> where Data: _PrimaryData, Data: Decodable, Included: _Included, Included: Decodable

/// Round trip tests.
final class DocumentTests: XCTestCase {

    // MARK: - Primary Data

    func testNilNullablePrimaryData_variantResourceRepresentable() throws {
        let document = Document(
            data: User?.none
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : null
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, Never>.self, from: encoded)
        XCTAssertNil(decoded.data)
    }

    func testNilNullablePrimaryData_variantResourceObject() throws {
        let document = Document(
            data: ResourceObject<User, User.Attributes, User.Relationships, User.Links, User.Meta>?.none
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : null
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, Never>.self, from: encoded)
        XCTAssertNil(decoded.data)
    }

    func testNilNullablePrimaryData_variantResourceIdentifierObject() throws {
        let document = Document(
            data: ResourceIdentifierObject<User, User.Meta>?.none
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : null
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<ResourceIdentifierObject<User, User.Meta>?, Never>.self, from: encoded)
        XCTAssertNil(decoded.data)
    }

    func testNonNilNullablePrimaryData_variantResourceRepresentable() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = Document(
            data: User?.some(user)
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              }
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, Never>.self, from: encoded)
        XCTAssertEqual(decoded.data.map(User.init), user)
    }

    func testNonNilNullablePrimaryData_variantResourceObject() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = Document(
            data: ResourceObject<User, User.Attributes, User.Relationships, User.Links, User.Meta>?.some(user.resourceObject)
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              }
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, Never>.self, from: encoded)
        XCTAssertEqual(decoded.data.map(User.init), user)
    }

    func testNonNilNullablePrimaryData_variantResourceIdentifierObject() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = Document(
            data: ResourceIdentifierObject<User, User.Meta>?.some(user.resourceIdentifierObject)
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "id" : "0",
                "type" : "user"
              }
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<ResourceIdentifierObject<User, User.Meta>?, Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, user.resourceIdentifierObject)
    }

    func testSingleResourcePrimaryData_variantResourceRepresentable() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = Document(
            data: user
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              }
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject, Never>.self, from: encoded)
        XCTAssertEqual(User(decoded.data), user)
    }

    func testSingleResourcePrimaryData_variantResourceObject() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = Document(
            data: user.resourceObject
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              }
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject, Never>.self, from: encoded)
        XCTAssertEqual(User(decoded.data), user)
    }

    func testSingleResourcePrimaryData_variantResourceIdentifierObject() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = Document(
            data: user.resourceIdentifierObject
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "id" : "0",
                "type" : "user"
              }
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<ResourceIdentifierObject<User, User.Meta>, Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, user.resourceIdentifierObject)
    }

    func testEmptyCollectionOfResourcesPrimaryData_variantResourceRepresentable() throws {
        let users: [User] = []
        let document = Document(
            data: users
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [

              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceObject))
    }

    func testEmptyCollectionOfResourcesPrimaryData_variantResourceObject() throws {
        let users: [User] = []
        let document = Document(
            data: users.map(\.resourceObject)
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [

              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceObject))
    }

    func testEmptyCollectionOfResourcesPrimaryData_variantResourceIdentifierObject() throws {
        let users: [User] = []
        let document = Document(
            data: users.map(\.resourceIdentifierObject)
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [

              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[ResourceIdentifierObject<User, User.Meta>], Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceIdentifierObject))
    }

    func testCollectionOfResourcesPrimaryData_variantResourceRepresentable() throws {
        let users = [
            User(id: 0, avatarID: 0, name: "John Doe"),
            User(id: 1, avatarID: 1, name: "Foo Bar")
        ]
        let document = Document(
            data: users
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [
                {
                  "attributes" : {
                    "name" : "John Doe"
                  },
                  "id" : "0",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                },
                {
                  "attributes" : {
                    "name" : "Foo Bar"
                  },
                  "id" : "1",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "1",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceObject))
    }

    func testCollectionOfResourcesPrimaryData_variantResourceObject() throws {
        let users = [
            User(id: 0, avatarID: 0, name: "John Doe"),
            User(id: 1, avatarID: 1, name: "Foo Bar")
        ]
        let document = Document(
            data: users.map(\.resourceObject)
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [
                {
                  "attributes" : {
                    "name" : "John Doe"
                  },
                  "id" : "0",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                },
                {
                  "attributes" : {
                    "name" : "Foo Bar"
                  },
                  "id" : "1",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "1",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceObject))
    }

    func testCollectionOfResourcesPrimaryData_variantResourceIdentifierObject() throws {
        let users = [
            User(id: 0, avatarID: 0, name: "John Doe"),
            User(id: 1, avatarID: 1, name: "Foo Bar")
        ]
        let document = Document(
            data: users.map(\.resourceIdentifierObject)
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [
                {
                  "id" : "0",
                  "type" : "user"
                },
                {
                  "id" : "1",
                  "type" : "user"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[ResourceIdentifierObject<User, User.Meta>], Never>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceIdentifierObject))
    }

    // MARK: - Primary Data with Included

    func testNilNullableCompoundPrimaryData_variantResourceRepresentable() throws {
        let document = try Document(
            data: User?.none?.including(\.avatarID, include: { Image(id: $0, creatorID: 0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : null,
              "included" : [

              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, DecodableIncluded>.self, from: encoded)
        XCTAssertNil(decoded.data)
        XCTAssertEqual(try decoded.included(via: \.avatarID), nil)
    }

    func testNilNullableCompoundPrimaryData_variantResourceObject() throws {
        let document = try Document(
            data: ResourceObject<User, User.Attributes, User.Relationships, User.Links, User.Meta>?.none?.including(\.avatarID, include: { Image(id: $0, creatorID: 0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : null,
              "included" : [

              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, DecodableIncluded>.self, from: encoded)
        XCTAssertNil(decoded.data)
        XCTAssertEqual(try decoded.included(via: \.avatarID), nil)
    }

    func testNonNilNullableCompoundPrimaryData_variantResourceRepresentable() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = try Document(
            data: User?.some(user)?.including(\.avatarID, include: { Image(id: $0, creatorID: 0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              },
              "included" : [
                {
                  "id" : "0",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, user.resourceObject)
        XCTAssertEqual(try decoded.included(via: \.avatarID), Image(id: 0, creatorID: 0).resourceObject)
    }

    func testNonNilNullableCompoundPrimaryData_variantResourceObject() throws {
        let user: User.ResourceObject? = User(id: 0, avatarID: 0, name: "John Doe").resourceObject
        let document = try Document(
            data: user?.including(\.avatarID, include: { Image(id: $0, creatorID: 0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              },
              "included" : [
                {
                  "id" : "0",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject?, DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, user)
        XCTAssertEqual(try decoded.included(via: \.avatarID), Image(id: 0, creatorID: 0).resourceObject)
    }

    func testSingleResourceCompoundPrimaryData_variantResourceRepresentable() throws {
        let user = User(id: 0, avatarID: 0, name: "John Doe")
        let document = try Document(
            data: user.including(\.avatarID, include: { Image(id: $0, creatorID: 0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              },
              "included" : [
                {
                  "id" : "0",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject, DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, user.resourceObject)
        XCTAssertEqual(try decoded.included(via: \.avatarID), Image(id: 0, creatorID: 0).resourceObject)
    }

    func testSingleResourceCompoundPrimaryData_variantResourceObject() throws {
        let user: User.ResourceObject = User(id: 0, avatarID: 0, name: "John Doe").resourceObject
        let document = try Document(
            data: user.including(\.avatarID, include: { Image(id: $0, creatorID: 0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "name" : "John Doe"
                },
                "id" : "0",
                "relationships" : {
                  "avatarID" : {
                    "data" : {
                      "id" : "0",
                      "type" : "image"
                    }
                  }
                },
                "type" : "user"
              },
              "included" : [
                {
                  "id" : "0",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<User.ResourceObject, DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, user)
        XCTAssertEqual(try decoded.included(via: \.avatarID), Image(id: 0, creatorID: 0).resourceObject)
    }

    func testEmptyCollectionOfResourcesCompoundPrimaryData_variantResourceRepresentable() throws {
        let document = try Document(
            data: [User]().including(\.avatarID, include: { Image(id: $0, creatorID: $0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [

              ],
              "included" : [

              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, [])
        XCTAssertEqual(try decoded.included(via: \.avatarID), [])
    }

    func testEmptyCollectionOfResourcesCompoundPrimaryData_variantResourceObject() throws {
        let document = try Document(
            data: [User.ResourceObject]().including(\.avatarID, include: { Image(id: $0, creatorID: $0) })
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [

              ],
              "included" : [

              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, [])
        XCTAssertEqual(try decoded.included(via: \.avatarID), [])
    }

    func testCollectionOfResourcesCompoundPrimaryData_variantResourceRepresentable() throws {
        let users: [User] = [
            User(id: 0, avatarID: 0, name: "John Doe"),
            User(id: 1, avatarID: 1, name: "Foo Bar")
        ]
        let document = try Document(
            data: users.including(\.avatarID, include: { Image(id: $0, creatorID: 0) }),
            sorted: true
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [
                {
                  "attributes" : {
                    "name" : "John Doe"
                  },
                  "id" : "0",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                },
                {
                  "attributes" : {
                    "name" : "Foo Bar"
                  },
                  "id" : "1",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "1",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                }
              ],
              "included" : [
                {
                  "id" : "0",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                },
                {
                  "id" : "1",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceObject))
        XCTAssertEqual(try decoded.included(via: \.avatarID), users.map({ Image(id: $0.avatarID!, creatorID: 0).resourceObject }))
    }

    func testCollectionOfResourcesCoumpoundPrimaryData_variantResourceObject() throws {
        let users: [User.ResourceObject] = [
            User(id: 0, avatarID: 0, name: "John Doe").resourceObject,
            User(id: 1, avatarID: 1, name: "Foo Bar").resourceObject
        ]
        let document = try Document(
            data: users.including(\.avatarID, include: { Image(id: $0, creatorID: 0) }),
            sorted: true
        )
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : [
                {
                  "attributes" : {
                    "name" : "John Doe"
                  },
                  "id" : "0",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                },
                {
                  "attributes" : {
                    "name" : "Foo Bar"
                  },
                  "id" : "1",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "1",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                }
              ],
              "included" : [
                {
                  "id" : "0",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                },
                {
                  "id" : "1",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "0",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<[User.ResourceObject], DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, users.map(\.resourceObject))
        XCTAssertEqual(try decoded.included(via: \.avatarID), users.map({ Image(id: $0.relationships.avatarID!.data.id, creatorID: 0).resourceObject }))
    }

    // MARK: - Encodable inclusion variants

    /// Tests:
    /// - nullable to-one with null for article.author.avatar.
    /// - nullable to-one with not null for article.coverImage
    /// - to-one article.author
    /// - to-many with empty for article.attachments
    /// - to-many with article.comments
    /// - inclusion of resource objects with indirect relationship via nested `including`
    func testChainedAndNestedInclusionWithAllKindsOfRelationships() throws {
        let article = Article(id: 0, authorID: 1, coverImageID: 2, title: "Article title", body: "Article body", attachmentIDs: [], commentIDs: [10, 11])
        let data = try article.including(\.authorID, include: {
            try User(id: $0, avatarID: nil, name: "User name") // tests nullable to-one with nil
                .including(\.avatarID, include: { Image(id: $0, creatorID: 3) }) // won't be included because the parent id is nil
        })
            .including(\.coverImageID, include: { // tests nullable to-one with not nil
                try Image(id: $0, creatorID: 4)
                    .including(\.creatorID, include: {
                        try User(id: $0, avatarID: 7, name: "Image 2 author")
                            .including(\.avatarID, include: { Image(id: $0, creatorID: 10) })
                    })
            })
            .including(\.attachmentIDs, include: { try Image(id: $0, creatorID: 22).including(\.creatorID, include: { User(id: $0, avatarID: nil, name: "Unexisting") }) }) // tests to-many with empty array
            .including(\.commentIDs, include: { try Comment(id: $0, text: "Comment text", userID: 8).including(\.userID, include: { User(id: $0, avatarID: nil, name: "Comment author") }) }) // tests to-many with non-empty array
        let document = Document(data: data, sorted: true)
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "data" : {
                "attributes" : {
                  "body" : "Article body",
                  "title" : "Article title"
                },
                "id" : "0",
                "relationships" : {
                  "attachmentIDs" : {
                    "data" : [

                    ]
                  },
                  "authorID" : {
                    "data" : {
                      "id" : "1",
                      "type" : "user"
                    }
                  },
                  "commentIDs" : {
                    "data" : [
                      {
                        "id" : "10",
                        "type" : "comment"
                      },
                      {
                        "id" : "11",
                        "type" : "comment"
                      }
                    ]
                  },
                  "coverImageID" : {
                    "data" : {
                      "id" : "2",
                      "type" : "image"
                    }
                  }
                },
                "type" : "article"
              },
              "included" : [
                {
                  "attributes" : {
                    "text" : "Comment text"
                  },
                  "id" : "10",
                  "relationships" : {
                    "userID" : {
                      "data" : {
                        "id" : "8",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "comment"
                },
                {
                  "attributes" : {
                    "text" : "Comment text"
                  },
                  "id" : "11",
                  "relationships" : {
                    "userID" : {
                      "data" : {
                        "id" : "8",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "comment"
                },
                {
                  "id" : "2",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "4",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                },
                {
                  "id" : "7",
                  "relationships" : {
                    "creatorID" : {
                      "data" : {
                        "id" : "10",
                        "type" : "user"
                      }
                    }
                  },
                  "type" : "image"
                },
                {
                  "attributes" : {
                    "name" : "User name"
                  },
                  "id" : "1",
                  "relationships" : {
                    "avatarID" : null
                  },
                  "type" : "user"
                },
                {
                  "attributes" : {
                    "name" : "Image 2 author"
                  },
                  "id" : "4",
                  "relationships" : {
                    "avatarID" : {
                      "data" : {
                        "id" : "7",
                        "type" : "image"
                      }
                    }
                  },
                  "type" : "user"
                },
                {
                  "attributes" : {
                    "name" : "Comment author"
                  },
                  "id" : "8",
                  "relationships" : {
                    "avatarID" : null
                  },
                  "type" : "user"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(SimpleDocument<Article.ResourceObject, DecodableIncluded>.self, from: encoded)
        XCTAssertEqual(decoded.data, article.resourceObject)
        // Direct relationships
        let decodedAuthor = try decoded.included(via: \.authorID)
        XCTAssertEqual(decodedAuthor, User(id: article.authorID, avatarID: nil, name: "User name").resourceObject)
        let decodedCoverImage = try decoded.included(via: \.coverImageID)
        XCTAssertEqual(decodedCoverImage, Image(id: 2, creatorID: 4).resourceObject)
        let decodedAttachments = try decoded.included(via: \.attachmentIDs)
        XCTAssertEqual(decodedAttachments, [])
        let decodedComments = try decoded.included(via: \.commentIDs)
        XCTAssertEqual(
            decodedComments,
            [Comment(id: 10, text: "Comment text", userID: 8).resourceObject, Comment(id: 11, text: "Comment text", userID: 8).resourceObject]
        )
        // Indirect relationships
        let decodedAuthorAvatar = try decoded.included(for: decodedAuthor, via: \.avatarID)
        XCTAssertEqual(decodedAuthorAvatar, nil)
        let decodedCoverImageCreator = try decoded.included(for: decodedCoverImage, via: \.creatorID)
        XCTAssertEqual(decodedCoverImageCreator, User(id: 4, avatarID: 7, name: "Image 2 author").resourceObject)
        let decodedCoverImageCreatorAvatar = try decoded.included(for: decodedCoverImageCreator, via: \.avatarID)
        XCTAssertEqual(decodedCoverImageCreatorAvatar, Image(id: 7, creatorID: 10).resourceObject)
        let decodedAttachmentsCreators = try decoded.included(for: decodedAttachments, via: \.creatorID)
        XCTAssertEqual(decodedAttachmentsCreators, [])
        let decodedCommentsUsers = try decoded.included(for: decodedComments, via: \.userID)
        XCTAssertEqual(decodedCommentsUsers, [User(id: 8, avatarID: nil, name: "Comment author").resourceObject, User(id: 8, avatarID: nil, name: "Comment author").resourceObject])
    }

    func testFailureResponse() throws {
        typealias MyError = ErrorObject<UUID, Never, Never, Int, String, Never, Never, Never>
        typealias FailureResponse = JSONAPI.FailureResponse<MyError, Never>
        let errorObject = MyError(id: UUID(uuidString: "AFA1C80F-0393-48A8-8A52-34B84A85B1CC")!, code: 123, title: "Whoops!")
        let document = Document(error: errorObject)
        let encoded = try JSONEncoder.pretty.encode(document)
        XCTAssertEqual(
            encoded.uft8String,
            """
            {
              "errors" : [
                {
                  "code" : "123",
                  "id" : "AFA1C80F-0393-48A8-8A52-34B84A85B1CC",
                  "title" : "Whoops!"
                }
              ]
            }
            """
        )
        let decoded = try JSONDecoder().decode(DecodableDocument<Document<User.ResourceObject, Never, Never, Never, Never, DecodableIncluded, FailureResponse>>.self, from: encoded)
        switch decoded {
            case .success: 
                XCTFail()
            case .failure(let errorDocument):
                XCTAssertEqual(errorDocument.errors, [errorObject])
        }
    }
}
